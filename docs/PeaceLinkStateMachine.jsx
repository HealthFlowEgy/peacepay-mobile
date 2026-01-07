import React, { useState, useCallback } from 'react';
import { ChevronRight, Circle, CheckCircle, XCircle, AlertCircle, Clock, Truck, Lock, Shield, DollarSign } from 'lucide-react';

const PeaceLinkStateMachine = () => {
  const [selectedState, setSelectedState] = useState(null);
  const [selectedTransition, setSelectedTransition] = useState(null);

  const states = {
    created: {
      label: 'Created',
      labelAr: 'تم الإنشاء',
      color: 'bg-gray-100 border-gray-400 text-gray-700',
      icon: Circle,
      description: 'Merchant creates PeaceLink request',
      walletImpact: {
        buyer: 'No change',
        merchant: 'No change',
        dsp: 'N/A',
        platform: 'No change'
      }
    },
    pending_approval: {
      label: 'Pending Approval',
      labelAr: 'في انتظار الموافقة',
      color: 'bg-amber-100 border-amber-400 text-amber-700',
      icon: Clock,
      description: 'SMS sent to buyer, awaiting approval',
      walletImpact: {
        buyer: 'No change',
        merchant: 'No change',
        dsp: 'N/A',
        platform: 'No change'
      }
    },
    sph_active: {
      label: 'SPH Active',
      labelAr: 'قيد الضمان',
      color: 'bg-blue-100 border-blue-400 text-blue-700',
      icon: Lock,
      description: 'Buyer approved & paid. Funds held in escrow.',
      walletImpact: {
        buyer: '−Total Amount (held)',
        merchant: '+Advance (if enabled)',
        dsp: 'N/A',
        platform: '+Advance Fee (if applicable)'
      }
    },
    dsp_assigned: {
      label: 'DSP Assigned',
      labelAr: 'تم تعيين المندوب',
      color: 'bg-purple-100 border-purple-400 text-purple-700',
      icon: Truck,
      description: 'Merchant assigned DSP wallet. OTP generated.',
      walletImpact: {
        buyer: 'No change (OTP sent)',
        merchant: 'No change',
        dsp: 'Pending',
        platform: 'No change'
      }
    },
    delivered: {
      label: 'Delivered',
      labelAr: 'تم التسليم',
      color: 'bg-green-100 border-green-400 text-green-700',
      icon: CheckCircle,
      description: 'OTP verified. Funds released to all parties.',
      walletImpact: {
        buyer: 'Escrow released',
        merchant: '+Item Amount − Fees',
        dsp: '+Delivery Fee − 0.5%',
        platform: '+All Fees'
      }
    },
    canceled: {
      label: 'Canceled',
      labelAr: 'ملغي',
      color: 'bg-red-100 border-red-400 text-red-700',
      icon: XCircle,
      description: 'Transaction canceled. Refund processed per rules.',
      walletImpact: {
        buyer: 'Per cancellation rules',
        merchant: 'Per cancellation rules',
        dsp: 'If assigned: Gets fee',
        platform: 'Keeps earned fees'
      }
    },
    disputed: {
      label: 'Disputed',
      labelAr: 'نزاع مفتوح',
      color: 'bg-orange-100 border-orange-400 text-orange-700',
      icon: AlertCircle,
      description: 'Dispute opened. All funds locked pending resolution.',
      walletImpact: {
        buyer: 'Locked',
        merchant: 'Locked',
        dsp: 'Locked',
        platform: 'Pending'
      }
    },
    resolved: {
      label: 'Resolved',
      labelAr: 'تم الحل',
      color: 'bg-teal-100 border-teal-400 text-teal-700',
      icon: Shield,
      description: 'Admin resolved dispute. Funds distributed per decision.',
      walletImpact: {
        buyer: 'Per admin decision',
        merchant: 'Per admin decision',
        dsp: 'Always paid if assigned',
        platform: 'Per admin decision'
      }
    },
    expired: {
      label: 'Expired',
      labelAr: 'منتهي',
      color: 'bg-gray-100 border-gray-300 text-gray-500',
      icon: Clock,
      description: 'Link expired without buyer action.',
      walletImpact: {
        buyer: 'No change',
        merchant: 'No change',
        dsp: 'N/A',
        platform: 'No change'
      }
    }
  };

  const transitions = [
    { from: 'created', to: 'pending_approval', trigger: 'SMS Sent', actor: 'System' },
    { from: 'created', to: 'expired', trigger: '24h Timeout', actor: 'System' },
    { from: 'pending_approval', to: 'sph_active', trigger: 'Buyer Approves', actor: 'Buyer', highlight: true },
    { from: 'pending_approval', to: 'expired', trigger: 'Link Expires', actor: 'System' },
    { from: 'pending_approval', to: 'canceled', trigger: 'Cancel', actor: 'Buyer/Merchant' },
    { from: 'sph_active', to: 'dsp_assigned', trigger: 'Assign DSP', actor: 'Merchant', highlight: true },
    { from: 'sph_active', to: 'canceled', trigger: 'Cancel (Full Refund)', actor: 'Buyer/Merchant', important: true },
    { from: 'dsp_assigned', to: 'delivered', trigger: 'Valid OTP', actor: 'DSP/Courier', highlight: true },
    { from: 'dsp_assigned', to: 'sph_active', trigger: 'DSP Cancels', actor: 'DSP' },
    { from: 'dsp_assigned', to: 'canceled', trigger: 'Cancel (Partial)', actor: 'Buyer', important: true },
    { from: 'dsp_assigned', to: 'canceled', trigger: 'Cancel (DSP Paid)', actor: 'Merchant', important: true },
    { from: 'dsp_assigned', to: 'disputed', trigger: 'Open Dispute', actor: 'Any Party' },
    { from: 'disputed', to: 'resolved', trigger: 'Admin Resolves', actor: 'Admin' },
  ];

  const cancellationRules = [
    {
      scenario: 'Buyer cancels before DSP',
      buyerRefund: 'Full (item + delivery)',
      dspPayout: 'N/A',
      merchantPayout: 'None',
      platformProfit: 'Kept if earned'
    },
    {
      scenario: 'Buyer cancels after DSP',
      buyerRefund: 'Item only',
      dspPayout: 'Delivery fee − 0.5%',
      merchantPayout: 'None',
      platformProfit: 'Kept'
    },
    {
      scenario: 'Merchant cancels before DSP',
      buyerRefund: 'Full',
      dspPayout: 'N/A',
      merchantPayout: 'None',
      platformProfit: 'Kept'
    },
    {
      scenario: 'Merchant cancels after DSP',
      buyerRefund: 'Full',
      dspPayout: 'Paid by Merchant',
      merchantPayout: '−Delivery fee',
      platformProfit: 'Kept'
    }
  ];

  const StateNode = ({ stateKey, state, isSelected, onClick }) => {
    const Icon = state.icon;
    return (
      <div
        onClick={() => onClick(stateKey)}
        className={`cursor-pointer p-4 rounded-xl border-2 transition-all duration-200 ${state.color} ${isSelected ? 'ring-4 ring-offset-2 ring-blue-500 scale-105' : 'hover:scale-102'}`}
      >
        <div className="flex items-center gap-3">
          <Icon className="w-6 h-6" />
          <div>
            <div className="font-semibold">{state.label}</div>
            <div className="text-sm opacity-70">{state.labelAr}</div>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">PeaceLink State Machine</h1>
          <p className="text-gray-600">Interactive visualization of Secure Payment Hold lifecycle</p>
        </div>

        {/* Main State Flow */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-6 flex items-center gap-2">
            <DollarSign className="w-5 h-5 text-green-600" />
            Transaction States
          </h2>
          
          {/* Happy Path */}
          <div className="flex items-center justify-between gap-4 mb-8 overflow-x-auto pb-4">
            {['created', 'pending_approval', 'sph_active', 'dsp_assigned', 'delivered'].map((key, idx, arr) => (
              <React.Fragment key={key}>
                <StateNode
                  stateKey={key}
                  state={states[key]}
                  isSelected={selectedState === key}
                  onClick={setSelectedState}
                />
                {idx < arr.length - 1 && (
                  <ChevronRight className="w-8 h-8 text-gray-400 flex-shrink-0" />
                )}
              </React.Fragment>
            ))}
          </div>

          {/* Alternative States */}
          <div className="flex gap-4 justify-center flex-wrap">
            {['canceled', 'disputed', 'resolved', 'expired'].map(key => (
              <StateNode
                key={key}
                stateKey={key}
                state={states[key]}
                isSelected={selectedState === key}
                onClick={setSelectedState}
              />
            ))}
          </div>
        </div>

        {/* Selected State Details */}
        {selectedState && (
          <div className="bg-white rounded-2xl shadow-xl p-8 mb-8 animate-fadeIn">
            <h2 className="text-xl font-semibold text-gray-700 mb-4">
              {states[selectedState].label} Details
            </h2>
            <p className="text-gray-600 mb-6">{states[selectedState].description}</p>
            
            <h3 className="font-medium text-gray-700 mb-3">Wallet Impact:</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {Object.entries(states[selectedState].walletImpact).map(([role, impact]) => (
                <div key={role} className="bg-gray-50 rounded-lg p-4">
                  <div className="text-sm text-gray-500 uppercase">{role}</div>
                  <div className="font-medium text-gray-800">{impact}</div>
                </div>
              ))}
            </div>

            {/* Outgoing Transitions */}
            <div className="mt-6">
              <h3 className="font-medium text-gray-700 mb-3">Possible Transitions:</h3>
              <div className="flex flex-wrap gap-2">
                {transitions
                  .filter(t => t.from === selectedState)
                  .map((t, idx) => (
                    <div
                      key={idx}
                      className={`px-4 py-2 rounded-full text-sm font-medium ${
                        t.highlight ? 'bg-green-100 text-green-700' :
                        t.important ? 'bg-red-100 text-red-700' :
                        'bg-gray-100 text-gray-700'
                      }`}
                    >
                      {t.trigger} → {states[t.to].label}
                      <span className="text-xs ml-2 opacity-70">({t.actor})</span>
                    </div>
                  ))}
              </div>
            </div>
          </div>
        )}

        {/* Cancellation Rules Matrix */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-6 flex items-center gap-2">
            <XCircle className="w-5 h-5 text-red-600" />
            Cancellation Rules Matrix
          </h2>
          
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50">
                  <th className="text-left p-4 font-semibold text-gray-700">Scenario</th>
                  <th className="text-left p-4 font-semibold text-gray-700">Buyer Refund</th>
                  <th className="text-left p-4 font-semibold text-gray-700">DSP Payout</th>
                  <th className="text-left p-4 font-semibold text-gray-700">Merchant</th>
                  <th className="text-left p-4 font-semibold text-gray-700">Platform</th>
                </tr>
              </thead>
              <tbody>
                {cancellationRules.map((rule, idx) => (
                  <tr key={idx} className={idx % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                    <td className="p-4 font-medium">{rule.scenario}</td>
                    <td className="p-4 text-blue-600">{rule.buyerRefund}</td>
                    <td className="p-4 text-purple-600">{rule.dspPayout}</td>
                    <td className="p-4 text-green-600">{rule.merchantPayout}</td>
                    <td className="p-4 text-amber-600">{rule.platformProfit}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Fee Structure */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <h2 className="text-xl font-semibold text-gray-700 mb-6 flex items-center gap-2">
            <DollarSign className="w-5 h-5 text-green-600" />
            Fee Structure
          </h2>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-green-50 rounded-xl p-6">
              <div className="text-green-600 font-semibold mb-2">Merchant Fee</div>
              <div className="text-3xl font-bold text-green-700">0.5% + 2 EGP</div>
              <div className="text-sm text-green-600 mt-2">Fixed fee on final release only</div>
            </div>
            <div className="bg-purple-50 rounded-xl p-6">
              <div className="text-purple-600 font-semibold mb-2">DSP Fee</div>
              <div className="text-3xl font-bold text-purple-700">0.5%</div>
              <div className="text-sm text-purple-600 mt-2">On delivery fee amount</div>
            </div>
            <div className="bg-blue-50 rounded-xl p-6">
              <div className="text-blue-600 font-semibold mb-2">Advance Fee</div>
              <div className="text-3xl font-bold text-blue-700">0.5%</div>
              <div className="text-sm text-blue-600 mt-2">No fixed fee on advance</div>
            </div>
            <div className="bg-amber-50 rounded-xl p-6">
              <div className="text-amber-600 font-semibold mb-2">Cash-out Fee</div>
              <div className="text-3xl font-bold text-amber-700">1.5%</div>
              <div className="text-sm text-amber-600 mt-2">Deducted at request time</div>
            </div>
          </div>
        </div>

        {/* Key Rules */}
        <div className="mt-8 bg-gradient-to-r from-green-600 to-teal-600 rounded-2xl shadow-xl p-8 text-white">
          <h2 className="text-xl font-semibold mb-4">🔒 Critical Invariants</h2>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-white/10 rounded-lg p-4">
              <div className="font-semibold">Ledger Balance</div>
              <div className="text-sm opacity-90">Buyer debit = Merchant + DSP + Platform</div>
            </div>
            <div className="bg-white/10 rounded-lg p-4">
              <div className="font-semibold">DSP Protection</div>
              <div className="text-sm opacity-90">Once assigned, DSP is guaranteed payment</div>
            </div>
            <div className="bg-white/10 rounded-lg p-4">
              <div className="font-semibold">OTP Authority</div>
              <div className="text-sm opacity-90">Valid OTP = definitive proof of delivery</div>
            </div>
            <div className="bg-white/10 rounded-lg p-4">
              <div className="font-semibold">Fee Freeze</div>
              <div className="text-sm opacity-90">Transaction fees frozen at creation time</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PeaceLinkStateMachine;
