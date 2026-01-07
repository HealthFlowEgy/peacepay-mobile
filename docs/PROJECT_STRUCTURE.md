# PeacePay Flutter Project Structure
# Clean Architecture with Riverpod State Management

```
peacepay_mobile/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── bootstrap.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_endpoints.dart
│   │   │   ├── storage_keys.dart
│   │   │   └── asset_paths.dart
│   │   │
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── environment.dart
│   │   │   └── flavors.dart
│   │   │
│   │   ├── di/
│   │   │   ├── injection_container.dart
│   │   │   └── providers.dart
│   │   │
│   │   ├── error/
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_handler.dart
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── dio_client.dart
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart
│   │   │   │   ├── error_interceptor.dart
│   │   │   │   ├── logging_interceptor.dart
│   │   │   │   └── retry_interceptor.dart
│   │   │   └── network_info.dart
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   ├── route_guards.dart
│   │   │   └── routes.dart
│   │   │
│   │   ├── services/
│   │   │   ├── local_storage_service.dart
│   │   │   ├── secure_storage_service.dart
│   │   │   ├── biometric_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   └── connectivity_service.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_shadows.dart
│   │   │   └── app_borders.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── extensions/
│   │   │   │   ├── context_extensions.dart
│   │   │   │   ├── string_extensions.dart
│   │   │   │   ├── date_extensions.dart
│   │   │   │   └── num_extensions.dart
│   │   │   ├── formatters/
│   │   │   │   ├── currency_formatter.dart
│   │   │   │   ├── phone_formatter.dart
│   │   │   │   └── date_formatter.dart
│   │   │   ├── validators/
│   │   │   │   ├── form_validators.dart
│   │   │   │   ├── egyptian_phone_validator.dart
│   │   │   │   └── national_id_validator.dart
│   │   │   └── helpers/
│   │   │       ├── debouncer.dart
│   │   │       └── platform_helper.dart
│   │   │
│   │   └── localization/
│   │       ├── app_localizations.dart
│   │       ├── l10n/
│   │       │   ├── app_ar.arb
│   │       │   └── app_en.arb
│   │       └── locale_provider.dart
│   │
│   ├── shared/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── wallet_model.dart
│   │   │   │   └── api_response_model.dart
│   │   │   └── repositories/
│   │   │       └── base_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── wallet_entity.dart
│   │   │   └── usecases/
│   │   │       └── usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── widgets/
│   │       │   ├── buttons/
│   │       │   │   ├── primary_button.dart
│   │       │   │   ├── secondary_button.dart
│   │       │   │   ├── danger_button.dart
│   │       │   │   ├── ghost_button.dart
│   │       │   │   └── icon_button.dart
│   │       │   ├── inputs/
│   │       │   │   ├── text_input.dart
│   │       │   │   ├── phone_input.dart
│   │       │   │   ├── amount_input.dart
│   │       │   │   ├── pin_input.dart
│   │       │   │   ├── otp_input.dart
│   │       │   │   ├── search_input.dart
│   │       │   │   └── dropdown_input.dart
│   │       │   ├── cards/
│   │       │   │   ├── wallet_card.dart
│   │       │   │   ├── peacelink_card.dart
│   │       │   │   ├── transaction_card.dart
│   │       │   │   └── notification_card.dart
│   │       │   ├── dialogs/
│   │       │   │   ├── confirmation_dialog.dart
│   │       │   │   ├── error_dialog.dart
│   │       │   │   └── success_dialog.dart
│   │       │   ├── sheets/
│   │       │   │   ├── bottom_sheet_base.dart
│   │       │   │   ├── pin_bottom_sheet.dart
│   │       │   │   └── action_sheet.dart
│   │       │   ├── indicators/
│   │       │   │   ├── loading_indicator.dart
│   │       │   │   ├── skeleton_loader.dart
│   │       │   │   └── progress_stepper.dart
│   │       │   ├── badges/
│   │       │   │   ├── status_badge.dart
│   │       │   │   └── kyc_badge.dart
│   │       │   └── layout/
│   │       │       ├── app_scaffold.dart
│   │       │       ├── safe_area_wrapper.dart
│   │       │       └── responsive_builder.dart
│   │       │
│   │       └── animations/
│   │           ├── fade_animation.dart
│   │           ├── slide_animation.dart
│   │           ├── success_animation.dart
│   │           └── confetti_animation.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── auth_token_model.dart
│   │   │   │   │   ├── otp_response_model.dart
│   │   │   │   │   └── login_request_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── auth_token_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── request_otp_usecase.dart
│   │   │   │       ├── verify_otp_usecase.dart
│   │   │   │       ├── setup_pin_usecase.dart
│   │   │   │       ├── verify_pin_usecase.dart
│   │   │   │       ├── refresh_token_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── auth_provider.dart
│   │   │       │   ├── auth_state.dart
│   │   │       │   └── auth_notifier.dart
│   │   │       ├── screens/
│   │   │       │   ├── splash_screen.dart
│   │   │       │   ├── phone_entry_screen.dart
│   │   │       │   ├── otp_verification_screen.dart
│   │   │       │   ├── pin_setup_screen.dart
│   │   │       │   ├── pin_entry_screen.dart
│   │   │       │   └── biometric_setup_screen.dart
│   │   │       └── widgets/
│   │   │           ├── phone_input_field.dart
│   │   │           ├── otp_countdown.dart
│   │   │           └── biometric_prompt.dart
│   │   │
│   │   ├── wallet/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── wallet_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── wallet_balance_model.dart
│   │   │   │   │   ├── transaction_model.dart
│   │   │   │   │   └── cashout_request_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── wallet_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── wallet_balance_entity.dart
│   │   │   │   │   └── transaction_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── wallet_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_balance_usecase.dart
│   │   │   │       ├── get_transactions_usecase.dart
│   │   │   │       └── request_cashout_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── wallet_provider.dart
│   │   │       │   └── transactions_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── wallet_screen.dart
│   │   │       │   ├── transaction_history_screen.dart
│   │   │       │   ├── transaction_detail_screen.dart
│   │   │       │   └── cashout_screen.dart
│   │   │       └── widgets/
│   │   │           ├── balance_display.dart
│   │   │           ├── transaction_list_item.dart
│   │   │           └── cashout_form.dart
│   │   │
│   │   ├── peacelink/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── peacelink_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── peacelink_model.dart
│   │   │   │   │   ├── create_peacelink_request.dart
│   │   │   │   │   ├── payout_model.dart
│   │   │   │   │   └── timeline_event_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── peacelink_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── peacelink_entity.dart
│   │   │   │   │   ├── peacelink_status.dart
│   │   │   │   │   └── cancellation_result_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── peacelink_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_peacelink_usecase.dart
│   │   │   │       ├── get_peacelink_usecase.dart
│   │   │   │       ├── list_peacelinks_usecase.dart
│   │   │   │       ├── approve_peacelink_usecase.dart
│   │   │   │       ├── assign_dsp_usecase.dart
│   │   │   │       ├── reassign_dsp_usecase.dart
│   │   │   │       ├── cancel_peacelink_usecase.dart
│   │   │   │       ├── confirm_delivery_usecase.dart
│   │   │   │       └── open_dispute_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── peacelink_provider.dart
│   │   │       │   ├── peacelink_list_provider.dart
│   │   │       │   ├── peacelink_detail_provider.dart
│   │   │       │   └── create_peacelink_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── buyer/
│   │   │       │   │   ├── peacelink_approval_screen.dart
│   │   │       │   │   ├── peacelink_detail_buyer_screen.dart
│   │   │       │   │   └── otp_display_screen.dart
│   │   │       │   ├── merchant/
│   │   │       │   │   ├── create_peacelink_screen.dart
│   │   │       │   │   ├── peacelink_detail_merchant_screen.dart
│   │   │       │   │   ├── assign_dsp_screen.dart
│   │   │       │   │   └── peacelink_list_screen.dart
│   │   │       │   └── dsp/
│   │   │       │       ├── delivery_list_screen.dart
│   │   │       │       ├── delivery_detail_screen.dart
│   │   │       │       └── otp_entry_screen.dart
│   │   │       └── widgets/
│   │   │           ├── peacelink_status_badge.dart
│   │   │           ├── peacelink_timeline.dart
│   │   │           ├── amount_breakdown.dart
│   │   │           ├── dsp_assignment_form.dart
│   │   │           ├── cancel_confirmation_sheet.dart
│   │   │           └── otp_display_card.dart
│   │   │
│   │   ├── dispute/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── dispute_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── dispute_model.dart
│   │   │   │   │   └── dispute_message_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── dispute_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── dispute_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── dispute_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── open_dispute_usecase.dart
│   │   │   │       ├── get_disputes_usecase.dart
│   │   │   │       └── add_message_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── dispute_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── dispute_list_screen.dart
│   │   │       │   ├── dispute_detail_screen.dart
│   │   │       │   └── open_dispute_screen.dart
│   │   │       └── widgets/
│   │   │           ├── dispute_message_bubble.dart
│   │   │           └── evidence_upload.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── profile_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── profile_model.dart
│   │   │   │   │   └── kyc_document_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── profile_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── profile_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── profile_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_profile_usecase.dart
│   │   │   │       ├── update_profile_usecase.dart
│   │   │   │       └── upload_kyc_document_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── profile_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   ├── edit_profile_screen.dart
│   │   │       │   ├── kyc_verification_screen.dart
│   │   │       │   └── settings_screen.dart
│   │   │       └── widgets/
│   │   │           ├── profile_header.dart
│   │   │           ├── kyc_status_card.dart
│   │   │           └── settings_tile.dart
│   │   │
│   │   ├── notifications/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── notifications_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── notification_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── notifications_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── notification_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── notifications_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_notifications_usecase.dart
│   │   │   │       └── mark_read_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── notifications_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── notifications_screen.dart
│   │   │       └── widgets/
│   │   │           └── notification_tile.dart
│   │   │
│   │   └── home/
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── home_provider.dart
│   │           ├── screens/
│   │           │   ├── buyer_home_screen.dart
│   │           │   ├── merchant_home_screen.dart
│   │           │   └── dsp_home_screen.dart
│   │           └── widgets/
│   │               ├── quick_actions.dart
│   │               ├── recent_activity.dart
│   │               └── stats_card.dart
│   │
│   └── l10n/
│       ├── app_ar.arb
│       └── app_en.arb
│
├── test/
│   ├── unit/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── wallet/
│   │   │   └── peacelink/
│   │   └── core/
│   ├── widget/
│   │   ├── shared/
│   │   └── features/
│   └── integration/
│       └── flows/
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── logo_dark.png
│   │   └── onboarding/
│   ├── icons/
│   │   └── custom_icons.ttf
│   ├── animations/
│   │   ├── success.json
│   │   ├── loading.json
│   │   └── confetti.json
│   └── fonts/
│       ├── Cairo/
│       └── Inter/
│
├── pubspec.yaml
├── analysis_options.yaml
├── .env.development
├── .env.staging
├── .env.production
└── README.md
```
