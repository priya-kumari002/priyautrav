const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'Shifter API',
    version: '1.0.0',
    description: 'OTP auth, transports, bookings for Shifter mobile app',
  },
  servers: [{ url: 'http://localhost:3000' }],
  paths: {
    '/api/auth/send-otp': {
      post: {
        summary: 'Send OTP to phone',
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  countryCode: { type: 'string', example: '+91' },
                  phone: { type: 'string', example: '9876543210' },
                },
                required: ['phone'],
              },
            },
          },
        },
      },
    },
    '/api/auth/verify-otp': {
      post: {
        summary: 'Verify OTP and get JWT',
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  countryCode: { type: 'string' },
                  phone: { type: 'string' },
                  otp: { type: 'string' },
                },
                required: ['phone', 'otp'],
              },
            },
          },
        },
      },
    },
    '/api/catalog/transports': {
      get: { summary: 'List transport types', security: [{ bearerAuth: [] }] },
    },
    '/api/catalog/recent-locations': {
      get: { summary: 'Recent locations for user', security: [{ bearerAuth: [] }] },
    },
    '/api/bookings': {
      get: { summary: 'List user bookings', security: [{ bearerAuth: [] }] },
      post: { summary: 'Create booking', security: [{ bearerAuth: [] }] },
    },
  },
  components: {
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
    },
  },
};

module.exports = { swaggerDocument };
