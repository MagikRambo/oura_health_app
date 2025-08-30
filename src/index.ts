import 'dotenv/config'; // <-- make sure this is line 1
import express from 'express';
import session from 'express-session';
import * as oidc from 'openid-client'; // v6 style – no named exports

const app = express();
const REDIRECT_URI = (process.env.OURA_REDIRECT_URI || '').trim();

// basic session for state & tokens
app.use(session({
  secret: 'dev-only-change-me',
  resave: false,
  saveUninitialized: true,
}));
const CLIENT_ID = process.env.OURA_CLIENT_ID;
const CLIENT_SECRET = process.env.OURA_CLIENT_SECRET;
const SCOPE = process.env.OURA_SCOPE || 'email personal daily';

if (!CLIENT_ID || !CLIENT_SECRET) {
  throw new Error('Missing OURA_CLIENT_ID and/or OURA_CLIENT_SECRET. Check your .env');
}

const AUTHORIZATION_ENDPOINT = 'https://cloud.ouraring.com/oauth/authorize';
const TOKEN_ENDPOINT = 'https://api.ouraring.com/oauth/token';

app.get('/', (_req, res) => {
  res.send(`<a href="/login">Connect Oura</a>`);
});
app.get('/login', (req, res) => {
  const state = oidc.randomState();
  (req.session as any).oauthState = state;

  const url = new URL(AUTHORIZATION_ENDPOINT);
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('client_id', CLIENT_ID!);
  // url.searchParams.set('redirect_uri', REDIRECT_URI);   // must match portal value exactly
  url.searchParams.set('scope', SCOPE);                 // start with: "email personal"
  url.searchParams.set('state', state);

  console.log('Auth redirect_uri = |' + REDIRECT_URI + '|'); // helps spot stray spaces
  res.redirect(url.toString());
});

app.get('/callback', async (req, res, next) => {
  try {
    if (req.query.error) {
      throw new Error(`${req.query.error}: ${req.query.error_description || ''}`);
    }
    const expectedState = (req.session as any).oauthState;
    if (!expectedState || req.query.state !== expectedState) {
      throw new Error('Invalid state');
    }

    const code = String(req.query.code || '');
    if (!code) throw new Error('Missing ?code');

    // Exchange code for tokens – Oura token endpoint
    // https://api.ouraring.com/docs/authentication#iii-exchange-code-for-access-token
    const basic = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');
    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      // redirect_uri: REDIRECT_URI,
    });

    const tokenResp = await fetch(TOKEN_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    if (!tokenResp.ok) {
      const text = await tokenResp.text();
      throw new Error(`Token error ${tokenResp.status}: ${text}`);
    }

    const tokens = await tokenResp.json() as {
      token_type: 'bearer';
      access_token: string;
      refresh_token?: string;
      expires_in: number;
      scope?: string;
    };

    (req.session as any).ouraTokens = tokens;

    // Sample call: get sleep data using the access token
    // https://api.ouraring.com/docs/authentication#using-the-access-token
    const sleepResp = await fetch('https://api.ouraring.com/v2/usercollection/sleep', {
      headers: { Authorization: `Bearer ${tokens.access_token}` },
    });
    const sleep = await sleepResp.json();

    res.json({ tokens, sampleSleep: sleep });
  } catch (err) {
    next(err);
  }
});

app.use((err: any, _req, res, _next) => {
  console.error(err);
  res.status(500).send(err?.message || 'Internal error');
});

app.listen(3000, () => {
  console.log('http://localhost:3000');
});

