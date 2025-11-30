---
id: "ADR-0014"
title: "Payment Processing & Stripe Integration"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-INTG-001, REQ-BILL-002"
decision_makers: "Platform Team"
consulted: "Finance, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0014: Payment Processing & Stripe Integration

## Context and Problem Statement

[REQ-INTG-001](../01-requirements/req-intg-001.md) requires Stripe payment integration for processing client payments. [REQ-BILL-002](../01-requirements/req-bill-002.md) requires online payment processing with multiple methods.

The platform must securely process payments for:
- One-time invoice payments
- Subscription/retainer billing
- Deposits on proposals

## Decision Drivers

- **Security:** PCI DSS compliance without storing card data
- **Laravel Integration:** Native Laravel support
- **Payment Methods:** Credit cards, ACH, international options
- **Subscriptions:** Recurring billing for retainers
- **Invoicing:** Link payments to invoices (ADR-0002)
- **Client Experience:** Smooth checkout from portal

## Considered Options

1. **Option A:** Stripe via Laravel Cashier
2. **Option B:** Stripe direct API integration
3. **Option C:** PayPal Commerce Platform
4. **Option D:** Square Payments
5. **Option E:** Authorize.net

## Decision Outcome

**Chosen Option:** Option A - Stripe via Laravel Cashier

**Justification:** Laravel Cashier provides:
- First-party Laravel package with excellent documentation
- Handles subscription lifecycle, webhooks, receipts
- Stripe Checkout for PCI-compliant hosted payment page
- Customer portal for self-service subscription management
- Payment method management (add/update cards)

Combined with ADR-0002 (Invoicing), Cashier provides the payment foundation.

### Consequences

#### Positive

- Official Laravel integration with best practices
- No card data touches our servers (Stripe Checkout/Elements)
- Automatic webhook handling for subscription events
- Built-in retry logic for failed payments
- Stripe's fraud protection and chargeback handling
- Support for 135+ currencies

#### Negative

- Stripe processing fees (2.9% + $0.30 per transaction)
- Tied to Stripe as payment processor
- Some features require Stripe Billing (additional 0.5% for invoices)
- Webhook handling requires careful implementation

#### Risks

- **Risk:** Webhook failures cause sync issues
  - **Mitigation:** Implement webhook verification; queue for reliability; monitor failures
- **Risk:** Failed payment retries annoy clients
  - **Mitigation:** Configure sensible retry schedules; send notifications before retry
- **Risk:** Chargebacks from unhappy clients
  - **Mitigation:** Clear invoicing; good client communication; dispute with evidence

## Validation

- **Metric 1:** Payment success rate >98%
- **Metric 2:** Checkout completion under 2 minutes
- **Metric 3:** Webhook processing within 5 seconds
- **Metric 4:** Zero PCI compliance issues

## Pros and Cons of the Options

### Option A: Stripe via Laravel Cashier

**Pros:**
- Official Laravel integration
- Subscription management included
- Stripe Checkout for PCI compliance
- Excellent documentation
- Active maintenance

**Cons:**
- Higher fees than some processors
- Stripe-specific abstractions
- Must use Stripe ecosystem

### Option B: Stripe Direct API

**Pros:**
- Maximum flexibility
- Access to all Stripe features
- No middleware abstraction

**Cons:**
- More code to write and maintain
- Must handle subscription logic
- Reinventing Cashier functionality

### Option C: PayPal Commerce

**Pros:**
- Wide consumer recognition
- No fees for PayPal balance payments
- International reach

**Cons:**
- Complex API/SDK
- Hold/reserve policies
- Higher fraud rates
- Less Laravel support

### Option D: Square Payments

**Pros:**
- Competitive rates
- Good for in-person + online
- Modern API

**Cons:**
- Less Laravel ecosystem support
- Smaller international presence
- Fewer subscription features

### Option E: Authorize.net

**Pros:**
- Established processor
- Good for high-risk businesses
- Multiple gateway options

**Cons:**
- Monthly fees + transaction fees
- Dated API
- Poor Laravel support
- Complex integration

## Implementation Notes

### Installation and Configuration

```bash
composer require laravel/cashier
php artisan vendor:publish --tag="cashier-migrations"
php artisan migrate
```

```php
// .env
STRIPE_KEY=pk_live_xxx
STRIPE_SECRET=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

// config/cashier.php
'currency' => 'usd',
'currency_locale' => 'en',
```

### Billable Model Setup

```php
// app/Models/Client.php
use Laravel\Cashier\Billable;

class Client extends Model
{
    use Billable;

    // Client is the billable entity, not User
    // Each client company has payment methods
}
```

### Payment Flows

#### One-Time Invoice Payment

```php
// Generate Stripe Checkout session for invoice
public function payInvoice(Invoice $invoice)
{
    return $invoice->client->checkout([
        'line_items' => [[
            'price_data' => [
                'currency' => 'usd',
                'product_data' => ['name' => "Invoice #{$invoice->number}"],
                'unit_amount' => $invoice->amount_cents,
            ],
            'quantity' => 1,
        ]],
        'mode' => 'payment',
        'success_url' => route('invoices.paid', $invoice),
        'cancel_url' => route('invoices.show', $invoice),
        'metadata' => ['invoice_id' => $invoice->id],
    ]);
}
```

#### Subscription (Retainer)

```php
// Create subscription for monthly retainer
public function subscribe(Client $client, string $plan)
{
    return $client->newSubscription('retainer', $plan)
        ->create($client->defaultPaymentMethod()->id);
}

// Cancel at period end
$client->subscription('retainer')->cancel();
```

### Webhook Handling

```php
// routes/web.php
Route::post('/stripe/webhook', [WebhookController::class, 'handleWebhook']);

// app/Http/Controllers/WebhookController.php
use Laravel\Cashier\Http\Controllers\WebhookController as CashierController;

class WebhookController extends CashierController
{
    public function handleInvoicePaid(array $payload)
    {
        // Mark our invoice as paid when Stripe invoice paid
        $stripeInvoiceId = $payload['data']['object']['id'];
        $invoice = Invoice::where('stripe_invoice_id', $stripeInvoiceId)->first();
        $invoice?->markPaid();
    }

    public function handlePaymentIntentSucceeded(array $payload)
    {
        // Handle one-time payments
        $metadata = $payload['data']['object']['metadata'];
        if (isset($metadata['invoice_id'])) {
            Invoice::find($metadata['invoice_id'])?->markPaid();
        }
    }
}
```

### Client Portal Payment Page

```php
// Blade template for invoice payment
@if($invoice->isPending())
    <form action="{{ route('invoices.checkout', $invoice) }}" method="POST">
        @csrf
        <button type="submit" class="btn btn-primary">
            Pay {{ $invoice->formatted_amount }}
        </button>
    </form>
@endif
```

### Stripe Dashboard Configuration

1. Create Products for subscription plans (Monthly Retainer, etc.)
2. Configure webhook endpoint: `https://app.example.com/stripe/webhook`
3. Select webhook events:
   - `checkout.session.completed`
   - `invoice.paid`
   - `invoice.payment_failed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `payment_intent.succeeded`
4. Enable Stripe Radar for fraud protection

## Links

- [REQ-INTG-001](../01-requirements/req-intg-001.md) - Stripe Payment Integration
- [REQ-BILL-002](../01-requirements/req-bill-002.md) - Online Payment Processing
- [REQ-BILL-003](../01-requirements/req-bill-003.md) - Subscription Management
- [ADR-0002](./adr-0002-invoicing-solution.md) - Invoicing Solution
- [Laravel Cashier Documentation](https://laravel.com/docs/billing)
- [Stripe API Documentation](https://stripe.com/docs/api)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
