# PeacePay Flutter App - Gap Fixes

**Date:** January 10, 2026
**Based on:** Test Cases Report, PeaceLink Test Scenarios, Features Document

## Summary of Fixes Applied

### 1. PeaceLink Details Screen (`peacelink_details_screen.dart`)

#### ✅ Scenario 5: Merchant Cannot Cancel After DSP Assigned
**Issue:** No cancellation button shown to merchant after DSP is assigned.
**Fix:** 
- Added `canMerchantCancel` check that allows cancellation for statuses: `created`, `approved`, `dsp_assigned`, `in_transit`
- Shows appropriate warning that merchant will pay DSP fee if canceling after DSP assigned

#### ✅ DSP Wallet Reassignment
**Issue:** Merchant cannot change DSP after assignment (before OTP).
**Fix:**
- Added `_ReassignDspDialog` for entering new DSP wallet number
- Added reassign button on DSP party card when `canReassignDsp` is true
- Logs reason for reassignment

#### ✅ Separated Fees for Merchant
**Issue:** Seller should see fees separated (item fee vs total).
**Fix:**
- Shows "رسوم المنصة (المنتج)" and "صافي المنتج" for merchant role
- Calculates: `itemPrice * 0.01 + 3` EGP

#### ✅ Policy Tab Hidden for Buyer
**Issue:** Policy Tab should be hidden for customer role.
**Fix:**
- Policy section only shown when `!isBuyer && pl.policyName != null`

#### ✅ BUG-003: OTP Visibility (Previously Fixed)
**Status:** Verified working with `shouldShowOtp` logic checking:
- User is buyer
- `otpVisible` flag from backend is true
- Status is `dspAssigned` or `inTransit`

---

### 2. Cash-out Screen (`cashout_screen.dart`)

#### ✅ Fee Not Deducted at Request Time
**Issue:** System deducted only requested amount, not amount + fee. Fee was supposed to be applied but wasn't deducted from wallet.
**Fix:**
- Calculate `_totalDeduction = _amount + _fee`
- Validate wallet has enough for total deduction
- Show clear breakdown: "إجمالي الخصم من المحفظة"
- Warning message: "سيتم خصم المبلغ والرسوم من محفظتك فور إرسال الطلب"
- Updated `requestCashout()` in provider to deduct full amount

---

### 3. Create PeaceLink Screen (`create_peacelink_screen.dart`)

#### ✅ Merchant Can Add DSP Wallet Before Buyer Approves
**Issue:** DSP wallet field visible and editable before buyer approval.
**Fix:**
- Removed DSP wallet input field entirely
- Added info message: "سيتم تعيين مندوب التوصيل بعد موافقة المشتري على الطلب"
- DSP assigned via separate flow after buyer approves

#### ✅ Delivery Fee Cannot Be Zero
**Issue:** Delivery fee shouldn't be 0.
**Fix:**
- Added validation: `if (fee == 0) return 'رسوم التوصيل لا يمكن أن تكون صفر'`

#### ✅ Advance Payment Toggle
**Issue:** Advanced Payment in policy shouldn't be mandatory.
**Fix:**
- Added `_enableAdvancePayment` toggle
- Slider for percentage (10-90%)
- Only included in request if enabled

#### ✅ Separated Fees in Summary
**Issue:** Seller should see separated fees.
**Fix:**
- Shows "رسوم المنصة (1% + 3)" and "صافي المنتج لك" in summary

---

### 4. Profile Screen (`profile_screen.dart`) - Previously Fixed

#### ✅ REQ-001: Multi-Role System
**Status:** Already implemented with `_RoleSwitcher` widget

#### ✅ Phone Number Not Editable
**Status:** Field marked as non-editable in profile

#### ✅ Country Field Removed
**Status:** Not present in profile form

---

### 5. Wallet Provider (`wallet_provider.dart`)

#### ✅ Cash-out with Fee at Request Time
**Fix:**
- `requestCashout()` now takes `fee` and `totalDeduction` parameters
- Deducts full amount (amount + fee) immediately
- Transaction record includes fee amount
- `refundCashout()` returns full amount including fee if rejected

---

### 6. Wallet Entity (`wallet.dart`)

#### ✅ Fee Field Added to Transaction
**Fix:**
- Added `fee` field to `Transaction` class
- Added `copyWith` for immutable updates

---

## Remaining Backend Dependencies

These issues were identified but require backend fixes (not frontend):

| ID | Issue | Backend Action Required |
|---|---|---|
| BUG-001 | Cancellation fee logic | Skip fee calculation if no DSP assigned |
| BUG-002 | DSP not paid on admin release | Ensure DSP payout in `release_to_seller` flow |
| Scenario 3 | PeacePay profit not updated on buyer cancel after DSP | Update profit ledger on DSP payout during cancel |
| Scenario 9 | Double fixed fee in advanced payment | Apply 3 EGP fixed fee only on final release, not on advance |

---

## Testing Checklist

- [ ] Merchant can cancel PeaceLink after DSP assigned
- [ ] Merchant sees warning about DSP fee when canceling
- [ ] Merchant can reassign DSP before OTP
- [ ] Buyer does not see policy tab
- [ ] Buyer sees OTP only when DSP assigned and in transit
- [ ] Cash-out deducts amount + fee at request time
- [ ] Cash-out shows total deduction clearly
- [ ] Create PeaceLink has no DSP wallet field
- [ ] Create PeaceLink validates delivery fee > 0
- [ ] Create PeaceLink shows separated fees for merchant
