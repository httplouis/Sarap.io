-- ============================================
-- SARAPIO DATABASE SCHEMA
-- Complete schema with all required tables
-- ============================================

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    avatar_seed TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================
-- 2. RECIPES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    minutes INT4,
    servings INT4,
    cuisine TEXT,
    region TEXT,
    ingredients JSONB,  -- Array of ingredient objects
    steps JSONB,        -- Array of step objects
    is_favorite BOOLEAN DEFAULT FALSE,
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipes_user_id ON recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at ON recipes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_recipes_is_favorite ON recipes(is_favorite);

-- ============================================
-- 3. INGREDIENTS TABLE (Optional - for detailed ingredient management)
-- ============================================
CREATE TABLE IF NOT EXISTS ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity TEXT
);

CREATE INDEX IF NOT EXISTS idx_ingredients_recipe_id ON ingredients(recipe_id);

-- ============================================
-- 4. STEPS TABLE (Optional - for detailed step management)
-- ============================================
CREATE TABLE IF NOT EXISTS steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    order_num INT4 NOT NULL,
    instruction TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_steps_recipe_id ON steps(recipe_id);
CREATE INDEX IF NOT EXISTS idx_steps_order ON steps(recipe_id, order_num);

-- ============================================
-- 5. POSTS TABLE (Social Feed)
-- ============================================
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author TEXT NOT NULL,
    caption TEXT,
    recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    likes INT4 DEFAULT 0,
    comments JSONB DEFAULT '[]'::jsonb,  -- Array of comment strings
    rating INT4 DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_recipe_id ON posts(recipe_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author);

-- ============================================
-- 6. NOTIFICATIONS TABLE (NEW - Missing from your schema!)
-- ============================================
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

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(user_id, is_read);

-- ============================================
-- ENABLE UUID EXTENSION (if not already enabled)
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users: Anyone can read, authenticated users can update their own
CREATE POLICY "Users are viewable by everyone" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (true);  -- Simplified for development

-- Recipes: Anyone can read, authenticated users can create/update/delete their own
CREATE POLICY "Recipes are viewable by everyone" ON recipes
    FOR SELECT USING (true);

CREATE POLICY "Anyone can create recipes" ON recipes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own recipes" ON recipes
    FOR UPDATE USING (true);  -- Simplified for development

CREATE POLICY "Users can delete own recipes" ON recipes
    FOR DELETE USING (true);  -- Simplified for development

-- Ingredients: Public read, authenticated write
CREATE POLICY "Ingredients are viewable by everyone" ON ingredients
    FOR SELECT USING (true);

CREATE POLICY "Anyone can manage ingredients" ON ingredients
    FOR ALL USING (true);  -- Simplified for development

-- Steps: Public read, authenticated write
CREATE POLICY "Steps are viewable by everyone" ON steps
    FOR SELECT USING (true);

CREATE POLICY "Anyone can manage steps" ON steps
    FOR ALL USING (true);  -- Simplified for development

-- Posts: Public read, authenticated write
CREATE POLICY "Posts are viewable by everyone" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Anyone can create posts" ON posts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update posts" ON posts
    FOR UPDATE USING (true);  -- Simplified for development

-- Notifications: Users can only see their own
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (true);  -- Simplified - in production, use: auth.uid() = user_id

CREATE POLICY "Anyone can create notifications" ON notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (true);  -- Simplified for development

-- ============================================
-- SUMMARY
-- ============================================
-- Total Tables: 6
-- 1. users
-- 2. recipes
-- 3. ingredients (optional - for detailed management)
-- 4. steps (optional - for detailed management)
-- 5. posts
-- 6. notifications (NEW - required for app functionality)

