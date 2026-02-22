/**
 * SpeakDine Stripe Payment Server
 *
 * Lightweight Express server handling Stripe operations.
 * Deploy on Render (free tier) with environment variables:
 *   STRIPE_SECRET_KEY, APP_BASE_URL, PORT
 */

const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY;
const APP_BASE_URL = process.env.APP_BASE_URL || 'http://localhost:5000';
const PORT = process.env.PORT || 3001;

if (!STRIPE_SECRET_KEY) {
  console.error('STRIPE_SECRET_KEY environment variable is required');
  process.exit(1);
}

const stripe = require('stripe')(STRIPE_SECRET_KEY);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

/**
 * Create a Stripe Customer for a user.
 * Body: { email, name, userId }
 * Returns: { customerId }
 */
app.post('/create-customer', async (req, res) => {
  try {
    const { email, name, userId } = req.body;

    if (!email || !userId) {
      return res.status(400).json({ error: 'email and userId are required' });
    }

    const customer = await stripe.customers.create({
      email,
      name: name || undefined,
      metadata: { firebaseUid: userId },
    });

    res.json({ customerId: customer.id });
  } catch (err) {
    console.error('[create-customer]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Create a Stripe Checkout Session for payment.
 * Body: { customerId, items: [{ name, quantity, priceInPaisa }], orderId, currency }
 * Returns: { url, sessionId }
 */
app.post('/create-checkout-session', async (req, res) => {
  try {
    const { customerId, items, orderId, currency } = req.body;

    if (!items || !items.length || !orderId) {
      return res.status(400).json({ error: 'items and orderId are required' });
    }

    const lineItems = items.map((item) => ({
      price_data: {
        currency: currency || 'pkr',
        product_data: { name: item.name },
        unit_amount: item.priceInPaisa,
      },
      quantity: item.quantity,
    }));

    const sessionParams = {
      mode: 'payment',
      line_items: lineItems,
      success_url: `${APP_BASE_URL}/#/payment-success?session_id={CHECKOUT_SESSION_ID}&order_id=${orderId}`,
      cancel_url: `${APP_BASE_URL}/#/payment-cancel?order_id=${orderId}`,
      metadata: { orderId },
    };

    if (customerId) {
      sessionParams.customer = customerId;
    }

    const session = await stripe.checkout.sessions.create(sessionParams);

    res.json({ url: session.url, sessionId: session.id });
  } catch (err) {
    console.error('[create-checkout-session]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Create a Stripe Checkout Session in setup mode (save card only).
 * Body: { customerId }
 * Returns: { url, sessionId }
 */
app.post('/create-setup-session', async (req, res) => {
  try {
    const { customerId } = req.body;

    if (!customerId) {
      return res.status(400).json({ error: 'customerId is required' });
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'setup',
      customer: customerId,
      success_url: `${APP_BASE_URL}/#/card-saved`,
      cancel_url: `${APP_BASE_URL}/#/card-save-cancel`,
      payment_method_types: ['card'],
    });

    res.json({ url: session.url, sessionId: session.id });
  } catch (err) {
    console.error('[create-setup-session]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Get saved payment methods for a customer.
 * Body: { customerId }
 * Returns: { cards: [{ id, brand, last4, expMonth, expYear }] }
 */
app.post('/get-saved-cards', async (req, res) => {
  try {
    const { customerId } = req.body;

    if (!customerId) {
      return res.status(400).json({ error: 'customerId is required' });
    }

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    const cards = paymentMethods.data.map((pm) => ({
      id: pm.id,
      brand: pm.card.brand,
      last4: pm.card.last4,
      expMonth: pm.card.exp_month,
      expYear: pm.card.exp_year,
    }));

    res.json({ cards });
  } catch (err) {
    console.error('[get-saved-cards]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Delete (detach) a saved payment method.
 * Body: { paymentMethodId }
 * Returns: { success: true }
 */
app.post('/delete-saved-card', async (req, res) => {
  try {
    const { paymentMethodId } = req.body;

    if (!paymentMethodId) {
      return res.status(400).json({ error: 'paymentMethodId is required' });
    }

    await stripe.paymentMethods.detach(paymentMethodId);

    res.json({ success: true });
  } catch (err) {
    console.error('[delete-saved-card]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Charge a saved card (for voice-command payments).
 * Body: { customerId, paymentMethodId, amountInPaisa, orderId, currency }
 * Returns: { success, paymentIntentId }
 */
app.post('/charge-saved-card', async (req, res) => {
  try {
    const { customerId, paymentMethodId, amountInPaisa, orderId, currency } =
      req.body;

    if (!customerId || !paymentMethodId || !amountInPaisa || !orderId) {
      return res.status(400).json({
        error:
          'customerId, paymentMethodId, amountInPaisa, and orderId are required',
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInPaisa,
      currency: currency || 'pkr',
      customer: customerId,
      payment_method: paymentMethodId,
      off_session: true,
      confirm: true,
      metadata: { orderId },
    });

    res.json({
      success: paymentIntent.status === 'succeeded',
      paymentIntentId: paymentIntent.id,
      status: paymentIntent.status,
    });
  } catch (err) {
    console.error('[charge-saved-card]', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`SpeakDine Stripe server running on port ${PORT}`);
});
