# ⚠️ MISSING TABLE: `notifications`

## Problem
Your database schema shows **5 tables**, but the app code uses **6 tables**:
- ✅ `users` - EXISTS
- ✅ `recipes` - EXISTS  
- ✅ `ingredients` - EXISTS
- ✅ `steps` - EXISTS
- ✅ `posts` - EXISTS
- ❌ **`notifications` - MISSING!**

## Solution

### Option 1: Run SQL Script (Recommended)
1. Open Supabase Dashboard
2. Go to **SQL Editor**
3. Copy and paste the `notifications` table creation from `DATABASE_SCHEMA.sql`:

```sql
-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,  -- 'like', 'comment', 'follow', 'save'
    message TEXT NOT NULL,
    related_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    related_recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(user_id, is_read);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (true);

CREATE POLICY "Anyone can create notifications" ON notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (true);
```

4. Click **Run**
5. Done! ✅

### Option 2: Use Supabase Table Editor
1. Go to **Table Editor** in Supabase
2. Click **New Table**
3. Name: `notifications`
4. Add columns:
   - `id` (uuid, primary key, default: uuid_generate_v4())
   - `user_id` (uuid, foreign key → users.id)
   - `type` (text, not null)
   - `message` (text, not null)
   - `related_user_id` (uuid, nullable, foreign key → users.id)
   - `related_recipe_id` (uuid, nullable, foreign key → recipes.id)
   - `is_read` (boolean, default: false)
   - `created_at` (timestamptz, default: now())
5. Save

## What This Table Does
The `notifications` table stores:
- Likes on your recipes
- Comments on your posts
- New followers
- Recipe saves
- Other social interactions

## Current Status
- ❌ **Without this table**: NotificationsView will show empty (no errors, just no data)
- ✅ **With this table**: Full notifications system works!

## Quick Test
After creating the table, test by:
1. Opening the app
2. Going to Notifications tab
3. Should see empty state (no errors)
4. When someone likes/comments, notifications will appear!

---

**Note**: The `ingredients` and `steps` tables in your schema are optional. The app uses the JSONB fields in the `recipes` table for ingredients and steps, but having separate tables gives you more flexibility for future features.

