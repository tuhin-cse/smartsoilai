# Farmbrite API Integration Guide

This guide explains how to integrate Farmbrite API for real-time field monitoring in the Smart Soil AI app.

## Setup Instructions

### 1. Get Farmbrite API Credentials

1. Sign up at [Farmbrite](https://farmbrite.com)
2. Go to Settings > API Keys
3. Generate a new API key
4. Copy the API key

### 2. Configure API Key

Update `lib/config/farmbrite_config.dart`:

```dart
class FarmbriteConfig {
  // Replace with your actual Farmbrite API key
  static const String apiKey = 'your_actual_api_key_here';
  // ... rest of the config
}
```

### 3. Get Your Field ID

1. Log into your Farmbrite dashboard
2. Navigate to your field
3. Copy the field ID from the URL or field details
4. Update the `defaultFieldId` in `farmbrite_config.dart`

### 4. API Endpoints Used

The app uses these Farmbrite API endpoints:

- `GET /v1/fields/{fieldId}` - Get field information
- `GET /v1/fields/{fieldId}/satellite-image` - Get satellite imagery

### 5. Data Mapping

The API response is mapped to display:

- **Field Size**: `area` or `size` field
- **Soil Moisture**: `soil_moisture` or `moisture` field (0-100%)
- **Crop Health**: `crop_health` or `health` field (0-100%)
- **Crop Type**: `crop_type` or `crop` field
- **Satellite Image**: `image_url` or `url` from satellite endpoint

### 6. Error Handling

The service includes comprehensive error handling for:
- Network errors
- Authentication failures (401)
- Field not found (404)
- Invalid API responses

### 7. Fallback Data

When API is not configured or fails, the app shows mock data for demonstration purposes.

## Features

- ✅ Real-time field monitoring
- ✅ Satellite imagery integration
- ✅ Soil moisture tracking
- ✅ Crop health assessment
- ✅ Automatic data refresh
- ✅ Error handling and retry
- ✅ Loading states
- ✅ Offline fallback

## Testing

To test the integration:

1. Configure your API key and field ID
2. Run the app
3. The satellite card will show real data
4. Tap the refresh button to update data
5. Check console for any API errors

## Troubleshooting

### Common Issues:

1. **401 Unauthorized**: Check your API key
2. **404 Not Found**: Verify the field ID
3. **Network Error**: Check internet connection
4. **Invalid Response**: API response format may have changed

### Debug Mode:

Enable debug logging in the service to see API requests and responses.

## API Documentation

For more details, refer to the [Farmbrite API Documentation](https://docs.farmbrite.com/).
