# Complete Setup Instructions

## Step 1: Clean Database (First Time Only)

If you want to start fresh:

```bash
cd /Users/jagadishpoudel/Development/django_/full_project
rm db.sqlite3  # Remove old database
```

## Step 2: Create Migrations

```bash
python3 manage.py makemigrations python_project
```

## Step 3: Apply Migrations

```bash
python3 manage.py migrate
```

This will create:
- All Django default tables (auth, sessions, etc.)
- `authtoken_token` table (for token-based auth)
- `python_project_skill` table (for skills)

## Step 4: Run Server

```bash
python3 manage.py runserver
```

## Step 5: Test Registration

In Flutter:
1. Go to Register screen
2. Create new user with:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm: `password123`
3. Should see "Registration successful!"
4. Automatically logs in

## Step 6: Test Login

1. Go to Login screen
2. Enter credentials from Step 5
3. Should see "Login successful!"

## Troubleshooting

### "no such table: authtoken_token"
- Run: `python3 manage.py migrate`

### "A user with that username already exists"
- Choose a different username, or
- Delete database and start fresh: `rm db.sqlite3 && python3 manage.py migrate`

### Still getting errors?
- Check console output for error messages
- Run: `python3 manage.py showmigrations` to see migration status
