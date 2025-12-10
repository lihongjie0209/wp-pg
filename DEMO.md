# WordPress + OpenHalo Demo Guide

This document provides a step-by-step demonstration of WordPress running on PostgreSQL via the OpenHalo compatibility layer.

## 📝 Demo Overview

This demo showcases:
1. Setting up WordPress with OpenHalo and PostgreSQL
2. Verifying the MySQL protocol compatibility
3. Creating content in WordPress
4. Confirming data is stored in PostgreSQL
5. Performance comparison observations

## 🚦 Step-by-Step Demonstration

### Step 1: Environment Setup

Start all services:

```bash
docker-compose up -d
```

**Expected Output:**
```
[+] Running 4/4
 ✔ Network wp-pg_wp-network      Created
 ✔ Container wp-postgres         Started
 ✔ Container wp-openhalo         Started
 ✔ Container wp-app              Started
```

### Step 2: Verify Service Health

Check that all services are running and healthy:

```bash
docker-compose ps
```

**Expected Output:**
```
NAME                IMAGE               STATUS              PORTS
wp-postgres         postgres:16-alpine  Up (healthy)        0.0.0.0:5432->5432/tcp
wp-openhalo         wp-pg-openhalo      Up (healthy)        0.0.0.0:3306->3306/tcp
wp-app              wordpress:latest    Up (healthy)        0.0.0.0:8080->80/tcp
```

### Step 3: Verify PostgreSQL Backend

Connect to PostgreSQL and verify the database:

```bash
docker-compose exec postgres psql -U wordpress -d wordpress -c "\dt"
```

**Expected Output:**
Initially, no tables exist (WordPress hasn't been installed yet):
```
Did not find any relations.
```

Check PostgreSQL version:

```bash
docker-compose exec postgres psql -U wordpress -d wordpress -c "SELECT version();"
```

### Step 4: Verify OpenHalo MySQL Protocol

Test MySQL protocol compatibility:

```bash
docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password -e "SELECT VERSION();"
```

**Expected Output:**
You should see OpenHalo responding to MySQL protocol commands while running on PostgreSQL.

### Step 5: Install WordPress

1. Open your browser to: `http://localhost:8080`

2. You should see the WordPress installation screen with language selection

3. Follow the installation wizard:
   - Select your language
   - Click "Continue"
   - WordPress will detect the database connection automatically
   - Fill in site information:
     - Site Title: "My OpenHalo WordPress Demo"
     - Username: admin
     - Password: (choose a strong password)
     - Email: your-email@example.com
   - Click "Install WordPress"

4. After successful installation, log in to the WordPress admin dashboard

### Step 6: Create Sample Content

1. Create a new post:
   - Go to Posts → Add New
   - Title: "Hello from PostgreSQL via OpenHalo!"
   - Content: "This WordPress site is running on PostgreSQL using the OpenHalo MySQL compatibility layer. No WordPress code modifications were needed!"
   - Click "Publish"

2. Create a new page:
   - Go to Pages → Add New
   - Title: "About This Demo"
   - Content: Add information about the setup
   - Click "Publish"

### Step 7: Verify Data in PostgreSQL

After creating content, verify that it's stored in PostgreSQL:

```bash
# List all tables created by WordPress
docker-compose exec postgres psql -U wordpress -d wordpress -c "\dt"
```

**Expected Output:**
```
              List of relations
 Schema |          Name           | Type  |   Owner
--------+-------------------------+-------+-----------
 public | wp_commentmeta          | table | wordpress
 public | wp_comments             | table | wordpress
 public | wp_links                | table | wordpress
 public | wp_options              | table | wordpress
 public | wp_postmeta             | table | wordpress
 public | wp_posts                | table | wordpress
 public | wp_term_relationships   | table | wordpress
 public | wp_term_taxonomy        | table | wordpress
 public | wp_termmeta             | table | wordpress
 public | wp_terms                | table | wordpress
 public | wp_usermeta             | table | wordpress
 public | wp_users                | table | wordpress
```

Check WordPress posts stored in PostgreSQL:

```bash
docker-compose exec postgres psql -U wordpress -d wordpress -c "SELECT post_title, post_status, post_type FROM wp_posts WHERE post_type IN ('post', 'page') AND post_status = 'publish';"
```

**Expected Output:**
```
           post_title            | post_status | post_type
---------------------------------+-------------+-----------
 Hello from PostgreSQL via...    | publish     | post
 About This Demo                 | publish     | page
```

### Step 8: Test WordPress Functionality

1. **Media Upload Test**
   - Go to Media → Add New
   - Upload an image
   - Verify it's accessible

2. **Plugin Installation Test**
   - Go to Plugins → Add New
   - Search for a simple plugin (e.g., "Hello Dolly")
   - Install and activate it
   - Verify it works

3. **Theme Change Test**
   - Go to Appearance → Themes
   - Activate a different theme
   - View the site to confirm the change

### Step 9: Performance Observations

Run a simple query performance test:

```bash
# WordPress posts query via MySQL protocol (OpenHalo)
time docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password wordpress -e "SELECT COUNT(*) FROM wp_posts;"

# Direct PostgreSQL query
time docker-compose exec postgres psql -U wordpress -d wordpress -c "SELECT COUNT(*) FROM wp_posts;"
```

### Step 10: Inspect OpenHalo Logs

View how OpenHalo translates MySQL queries:

```bash
docker-compose logs openhalo | tail -50
```

You should see logs showing MySQL protocol connections and query translations.

## 🎯 Demo Verification Checklist

- [ ] All Docker containers started successfully
- [ ] PostgreSQL is accessible and healthy
- [ ] OpenHalo is listening on port 3306 (MySQL protocol)
- [ ] WordPress installation completed successfully
- [ ] WordPress admin dashboard is accessible
- [ ] Posts and pages can be created
- [ ] Data is confirmed in PostgreSQL tables
- [ ] Media uploads work correctly
- [ ] Plugins can be installed and activated
- [ ] Themes can be changed
- [ ] No WordPress errors in logs

## 🔧 Advanced Testing

### Test MySQL Client Compatibility

Use a standard MySQL client to connect to OpenHalo:

```bash
docker run -it --rm --network wp-pg_wp-network mysql:8 mysql -h wp-openhalo -P 3306 -u wordpress -pwordpress_password wordpress -e "SHOW TABLES;"
```

### Test Query Translation

Execute MySQL-specific queries and see how OpenHalo handles them:

```bash
docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password wordpress -e "SHOW DATABASES;"
docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password wordpress -e "SHOW TABLES;"
docker-compose exec openhalo mysql -h localhost -P 3306 -u wordpress -pwordpress_password wordpress -e "DESCRIBE wp_posts;"
```

### Stress Test

Create multiple posts to test performance:

```bash
docker-compose exec wordpress wp post generate --count=100 --post_type=post --allow-root
```

Then query the data:

```bash
docker-compose exec postgres psql -U wordpress -d wordpress -c "SELECT COUNT(*) FROM wp_posts WHERE post_type = 'post';"
```

## 📸 Screenshots

When running this demo, capture screenshots of:

1. Docker Compose services running (`docker-compose ps`)
2. WordPress installation screen
3. WordPress dashboard after installation
4. A published post in WordPress
5. PostgreSQL query results showing WordPress tables
6. PostgreSQL query results showing post content

## 🎓 Learning Outcomes

After completing this demo, you will have learned:

1. How OpenHalo provides MySQL wire protocol compatibility for PostgreSQL
2. How to run WordPress on PostgreSQL without code modifications
3. How to verify data flow between WordPress, OpenHalo, and PostgreSQL
4. How to troubleshoot multi-container Docker applications
5. The benefits and trade-offs of using a compatibility layer

## 📊 Next Steps

1. Try migrating an existing MySQL WordPress site to this setup
2. Test more WordPress plugins for compatibility
3. Benchmark performance differences between MySQL and OpenHalo/PostgreSQL
4. Explore OpenHalo's migration tools for existing databases
5. Test failover and backup scenarios

## 🐛 Common Issues and Solutions

### Issue: OpenHalo container fails to start
**Solution:** Check build logs and ensure all dependencies are installed correctly
```bash
docker-compose logs openhalo
docker-compose build --no-cache openhalo
```

### Issue: WordPress shows "Error establishing database connection"
**Solution:** Verify OpenHalo is listening on port 3306
```bash
docker-compose exec openhalo netstat -tlnp | grep 3306
```

### Issue: Slow performance
**Solution:** Increase Docker resource limits and PostgreSQL shared_buffers
- Edit docker-compose.yml to add resource limits
- Adjust PostgreSQL configuration in openhalo/entrypoint.sh

## 🎉 Conclusion

This demo shows that WordPress can successfully run on PostgreSQL using OpenHalo as a compatibility layer, with minimal configuration changes and no WordPress code modifications required.

For detailed findings and conclusions, see [CONCLUSION.md](./CONCLUSION.md).
