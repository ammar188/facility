-- ============================================
-- Test Conversation Insert
-- ============================================
-- This script helps you test if RLS policies work
-- ============================================

-- Step 1: Get your user ID from the auth.users table
-- Replace 'your-email@example.com' with your actual email
SELECT 
  'Your user ID:' as info,
  id as user_id,
  email
FROM auth.users
WHERE email = 'your-email@example.com';

-- Step 2: Once you have your user ID, test the insert
-- Replace 'YOUR_USER_ID_HERE' with the actual UUID from step 1
-- This simulates what happens when an authenticated user inserts
INSERT INTO public."Conversation" (user_id, vendor_id)
VALUES ('YOUR_USER_ID_HERE'::uuid, 'YOUR_USER_ID_HERE'::uuid)
RETURNING id, user_id, vendor_id, created_at;

-- Step 3: Check if the insert worked
SELECT 
  'Conversations created:' as info,
  id,
  user_id,
  vendor_id,
  created_at
FROM public."Conversation"
ORDER BY created_at DESC
LIMIT 5;

