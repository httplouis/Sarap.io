# Network Connection Troubleshooting

## Issue: "A server with the specified hostname could not be found"

This error means the app cannot connect to Supabase. Here are solutions:

### 1. Check Internet Connection
- Make sure your Mac/simulator has internet access
- Try opening `https://tmrdvhvhvcfmijvjkzytv.supabase.co` in a browser

### 2. Simulator Network Issues
- **Reset Simulator Network**: 
  - Device → Erase All Content and Settings
  - Or restart the simulator
  
### 3. DNS Issues
- Try using a different DNS (8.8.8.8 or 1.1.1.1)
- Or restart your router

### 4. Supabase Project Status
- Check if your Supabase project is active (not paused)
- Verify the URL is correct: `https://tmrdvhvhvcfmijvjkzytv.supabase.co`

### 5. Firewall/VPN
- Disable VPN if active
- Check firewall settings
- Try a different network

### 6. Test Connection
Run this in terminal:
```bash
curl -I https://tmrdvhvhvcfmijvjkzytv.supabase.co
```

If this fails, it's a network/DNS issue, not an app issue.

### Quick Fixes:
1. Restart simulator
2. Restart Xcode
3. Check WiFi connection
4. Try on a physical device instead of simulator

