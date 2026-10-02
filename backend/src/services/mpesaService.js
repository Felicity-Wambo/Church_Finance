const axios = require('axios');

class MpesaService {
  constructor() {
    this.consumerKey = process.env.MPESA_CONSUMER_KEY;
    this.consumerSecret = process.env.MPESA_CONSUMER_SECRET;
    this.passkey = process.env.MPESA_PASSKEY;
    this.shortcode = process.env.MPESA_SHORTCODE;

    this.callbackUrl = process.env.MPESA_CALLBACK_URL;

    this.baseUrl = 'https://sandbox.safaricom.co.ke';

    this.isMockMode =
      !this.consumerKey ||
      !this.consumerSecret ||
      !this.passkey ||
      !this.shortcode ||
      this.consumerKey === 'your_consumer_key';

    console.log('======================================');
    console.log('📱 M-PESA SERVICE');
    console.log('======================================');
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Mode: ${this.isMockMode ? 'MOCK' : 'SANDBOX'}`);
    console.log(`Shortcode: ${this.shortcode || 'Not configured'}`);
    console.log(`Callback URL: ${this.callbackUrl || 'Not configured'}`);
    console.log('======================================');
  }

  /**
   * Format Kenyan phone number
   */
  formatPhoneNumber(phoneNumber) {
    if (!phoneNumber) {
      throw new Error('Phone number is required');
    }

    let phone = String(phoneNumber)
      .replace(/\s/g, '')
      .replace(/-/g, '');

    if (phone.startsWith('+254')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('0')) {
      phone = '254' + phone.substring(1);
    }

    if (!phone.startsWith('254')) {
      phone = '254' + phone;
    }

    if (!/^2547\d{8}$/.test(phone)) {
      throw new Error(
        'Invalid Kenyan phone number. Use format 07XXXXXXXX or 2547XXXXXXXX'
      );
    }

    return phone;
  }

  /**
   * Generate M-Pesa timestamp
   */
  getTimestamp() {
    const now = new Date();

    const pad = (number) => String(number).padStart(2, '0');

    return (
      now.getFullYear() +
      pad(now.getMonth() + 1) +
      pad(now.getDate()) +
      pad(now.getHours()) +
      pad(now.getMinutes()) +
      pad(now.getSeconds())
    );
  }

  /**
   * Generate STK password
   */
  generatePassword(timestamp) {
    return Buffer.from(
      `${this.shortcode}${this.passkey}${timestamp}`
    ).toString('base64');
  }

  /**
   * Get OAuth access token
   */
  async getAccessToken() {
    if (this.isMockMode) {
      return 'mock_token';
    }

    try {
      const credentials = Buffer.from(
        `${this.consumerKey}:${this.consumerSecret}`
      ).toString('base64');

      const response = await axios.get(
        `${this.baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
        {
          headers: {
            Authorization: `Basic ${credentials}`,
          },
          timeout: 15000,
        }
      );

      return response.data.access_token;
    } catch (error) {
      console.error(
        '❌ M-Pesa Access Token Error:',
        error.response?.data || error.message
      );

      throw new Error('Failed to obtain M-Pesa access token');
    }
  }

  /**
   * Initiate STK Push
   */
  async stkPush(
    phoneNumber,
    amount,
    accountReference,
    transactionDesc
  ) {
    const formattedPhone = this.formatPhoneNumber(phoneNumber);

    const roundedAmount = Math.round(Number(amount));

    if (!roundedAmount || roundedAmount < 1) {
      throw new Error('Amount must be at least KSh 1');
    }

    const reference =
      String(accountReference || `GIVING${Date.now()}`)
        .substring(0, 12);

    const description =
      String(transactionDesc || 'Church Giving')
        .substring(0, 13);

    /**
     * MOCK MODE
     */
    if (this.isMockMode) {
      console.log('📱 MOCK STK PUSH');
      console.log(`Phone: ${formattedPhone}`);
      console.log(`Amount: KSh ${roundedAmount}`);
      console.log(`Reference: ${reference}`);

      return {
        MerchantRequestID: `MOCK-MERCHANT-${Date.now()}`,
        CheckoutRequestID: `MOCK-CHECKOUT-${Date.now()}`,
        ResponseCode: '0',
        ResponseDescription:
          'Success. Request accepted for processing',
        CustomerMessage:
          'Success. Request accepted for processing',
        isMock: true,
      };
    }

    try {
      const token = await this.getAccessToken();

      const timestamp = this.getTimestamp();

      const password = this.generatePassword(timestamp);

      const requestData = {
        BusinessShortCode: Number(this.shortcode),
        Password: password,
        Timestamp: timestamp,

        TransactionType: 'CustomerPayBillOnline',

        Amount: roundedAmount,

        PartyA: formattedPhone,

        PartyB: Number(this.shortcode),

        PhoneNumber: formattedPhone,

        CallBackURL: this.callbackUrl,

        AccountReference: reference,

        TransactionDesc: description,
      };

      console.log('======================================');
      console.log('📱 STK PUSH REQUEST');
      console.log('======================================');

      console.log({
        ...requestData,

        // Never log the password
        Password: '********',
      });

      const response = await axios.post(
        `${this.baseUrl}/mpesa/stkpush/v1/processrequest`,
        requestData,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000,
        }
      );

      console.log('======================================');
      console.log('📱 STK PUSH RESPONSE');
      console.log('======================================');

      console.log(response.data);

      return {
        MerchantRequestID: response.data.MerchantRequestID,
        CheckoutRequestID: response.data.CheckoutRequestID,
        ResponseCode: String(response.data.ResponseCode),
        ResponseDescription: response.data.ResponseDescription,
        CustomerMessage: response.data.CustomerMessage,
        isMock: false,
      };
    } catch (error) {
      console.error(
        '❌ STK Push Error:',
        error.response?.data || error.message
      );

      // IMPORTANT:
      // Do NOT pretend a real failed M-Pesa request succeeded.
      throw new Error(
        error.response?.data?.errorMessage ||
        error.response?.data?.ResponseDescription ||
        error.message ||
        'M-Pesa STK Push failed'
      );
    }
  }

  /**
   * Query STK transaction status
   */
  async queryStatus(checkoutRequestId) {
    if (!checkoutRequestId) {
      throw new Error('CheckoutRequestID is required');
    }

    if (this.isMockMode) {
      return {
        ResponseCode: '0',
        ResponseDescription:
          'Success. Request accepted for processing',
        ResultCode: '0',
        ResultDesc:
          'The service request was processed successfully',
      };
    }

    try {
      const token = await this.getAccessToken();

      const timestamp = this.getTimestamp();

      const password = this.generatePassword(timestamp);

      const response = await axios.post(
        `${this.baseUrl}/mpesa/stkpushquery/v1/query`,
        {
          BusinessShortCode: Number(this.shortcode),
          Password: password,
          Timestamp: timestamp,
          CheckoutRequestID: checkoutRequestId,
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000,
        }
      );

      return response.data;
    } catch (error) {
      console.error(
        '❌ M-Pesa Query Error:',
        error.response?.data || error.message
      );

      throw new Error(
        error.response?.data?.errorMessage ||
        error.message ||
        'Failed to query M-Pesa transaction'
      );
    }
  }
}

module.exports = new MpesaService();