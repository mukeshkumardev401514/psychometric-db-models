DO $$
DECLARE
    v_tenant_id UUID := 'cc034bd1-b1cb-4625-9c14-3d9ff57ff531';
    v_assessment_id UUID := '495e17c3-39c4-4662-8928-ebd32c04aaf6';
    v_version_id UUID := '83f1c02a-45da-4bb6-9457-bd3977c2049a';

    v_plan_id UUID;
    v_subscription_id UUID;
    v_payment_id UUID;
    v_payout_account_id UUID;
    v_payout_batch_id UUID;
    v_doctor_payout_id UUID;

    v_doctor_id UUID := '00000000-0000-0000-0000-000000000001';

BEGIN

    -- ========================================================
    -- 1. Get existing subscription plan
    -- ========================================================

    SELECT id
    INTO v_plan_id
    FROM subscription_plans
    WHERE code = 'PRO_MONTHLY';

    IF v_plan_id IS NULL THEN

        INSERT INTO subscription_plans (
            code,
            name,
            description,
            price,
            currency,
            billing_interval,
            status
        )
        VALUES (
            'PRO_MONTHLY',
            'Professional Monthly',
            'Professional subscription plan.',
            2499.00,
            'INR',
            'MONTHLY',
            'ACTIVE'
        )
        RETURNING id INTO v_plan_id;

    END IF;


    -- ========================================================
    -- 2. Get existing MVW active subscription
    -- ========================================================

    SELECT id
    INTO v_subscription_id
    FROM tenant_subscriptions
    WHERE tenant_id = v_tenant_id
      AND status IN ('TRIAL', 'ACTIVE', 'PAST_DUE')
    ORDER BY created_at DESC
    LIMIT 1;


    -- Create only if subscription does not exist
    IF v_subscription_id IS NULL THEN

        INSERT INTO tenant_subscriptions (
            tenant_id,
            subscription_plan_id,
            status,
            start_at,
            end_at,
            auto_renew
        )
        VALUES (
            v_tenant_id,
            v_plan_id,
            'ACTIVE',
            NOW(),
            NOW() + INTERVAL '1 month',
            TRUE
        )
        RETURNING id INTO v_subscription_id;

    END IF;


    -- ========================================================
    -- 3. Check if demo payment already exists
    -- ========================================================

    SELECT id
    INTO v_payment_id
    FROM platform_payments
    WHERE razorpay_order_id = 'order_demo_mvw_001'
    LIMIT 1;


    -- ========================================================
    -- 4. Create payment only if it doesn't exist
    -- ========================================================

    IF v_payment_id IS NULL THEN

        INSERT INTO platform_payments (
            tenant_id,
            assessment_id,
            assessment_version_id,
            assignment_id,
            doctor_id,
            patient_id,
            amount,
            currency,
            doctor_percentage,
            platform_percentage,
            doctor_amount,
            platform_amount,
            status,
            razorpay_order_id,
            razorpay_payment_id,
            paid_at
        )
        VALUES (
            v_tenant_id,
            v_assessment_id,
            v_version_id,
            '00000000-0000-0000-0000-000000000003',
            v_doctor_id,
            '00000000-0000-0000-0000-000000000002',
            999.00,
            'INR',
            70.00,
            30.00,
            699.30,
            299.70,
            'PAID',
            'order_demo_mvw_001',
            'pay_demo_mvw_001',
            NOW()
        )
        RETURNING id INTO v_payment_id;

    END IF;


    -- ========================================================
    -- 5. Payment Event
    -- ========================================================

    INSERT INTO payment_events (
        payment_id,
        razorpay_event_id,
        event_type,
        payload,
        status,
        processed_at
    )
    VALUES (
        v_payment_id,
        'evt_demo_mvw_001',
        'payment.captured',
        jsonb_build_object(
            'demo', true,
            'amount', 99900,
            'currency', 'INR',
            'status', 'captured'
        ),
        'PROCESSED',
        NOW()
    )
    ON CONFLICT (razorpay_event_id)
    DO NOTHING;


    -- ========================================================
    -- 6. Doctor UPI Account
    -- ========================================================

    SELECT id
    INTO v_payout_account_id
    FROM doctor_payout_accounts
    WHERE tenant_id = v_tenant_id
      AND doctor_id = v_doctor_id
      AND upi_id = 'doctor.demo@upi'
    LIMIT 1;


    IF v_payout_account_id IS NULL THEN

        INSERT INTO doctor_payout_accounts (
            tenant_id,
            doctor_id,
            payout_method,
            upi_id,
            account_holder_name,
            status,
            verified_at
        )
        VALUES (
            v_tenant_id,
            v_doctor_id,
            'UPI',
            'doctor.demo@upi',
            'Demo Doctor',
            'VERIFIED',
            NOW()
        )
        RETURNING id INTO v_payout_account_id;

    END IF;


    -- ========================================================
    -- 7. Daily Payout Batch
    -- ========================================================

    SELECT id
    INTO v_payout_batch_id
    FROM payout_batches
    WHERE batch_date = CURRENT_DATE
      AND payout_mode = 'DAILY_BATCH'
    LIMIT 1;


    IF v_payout_batch_id IS NULL THEN

        INSERT INTO payout_batches (
            batch_date,
            payout_mode,
            status,
            total_amount,
            total_doctor_count
        )
        VALUES (
            CURRENT_DATE,
            'DAILY_BATCH',
            'PENDING',
            699.30,
            1
        )
        RETURNING id INTO v_payout_batch_id;

    END IF;


    -- ========================================================
    -- 8. Doctor Payout
    -- ========================================================

    SELECT id
    INTO v_doctor_payout_id
    FROM doctor_payouts
    WHERE payout_batch_id = v_payout_batch_id
      AND doctor_id = v_doctor_id
    LIMIT 1;


    IF v_doctor_payout_id IS NULL THEN

        INSERT INTO doctor_payouts (
            payout_batch_id,
            tenant_id,
            doctor_id,
            payout_account_id,
            payout_mode,
            amount,
            currency,
            status
        )
        VALUES (
            v_payout_batch_id,
            v_tenant_id,
            v_doctor_id,
            v_payout_account_id,
            'DAILY_BATCH',
            699.30,
            'INR',
            'PENDING'
        )
        RETURNING id INTO v_doctor_payout_id;

    END IF;


    -- ========================================================
    -- 9. Link payment with payout
    -- ========================================================

    INSERT INTO doctor_payout_items (
        doctor_payout_id,
        payment_id,
        doctor_amount
    )
    VALUES (
        v_doctor_payout_id,
        v_payment_id,
        699.30
    )
    ON CONFLICT (payment_id)
    DO NOTHING;


    -- ========================================================
    -- 10. Output
    -- ========================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Financial seed completed';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Subscription ID : %', v_subscription_id;
    RAISE NOTICE 'Payment ID      : %', v_payment_id;
    RAISE NOTICE 'Payout Account  : %', v_payout_account_id;
    RAISE NOTICE 'Payout Batch    : %', v_payout_batch_id;
    RAISE NOTICE 'Doctor Payout   : %', v_doctor_payout_id;
    RAISE NOTICE '========================================';

END $$;