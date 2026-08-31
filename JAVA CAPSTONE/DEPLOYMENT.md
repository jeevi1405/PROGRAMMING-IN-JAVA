# Deployment Guide: SIMATS Skill Progress Analytics Web Application

This document provides step-by-step instructions to deploy the **SIMATS Skill Progress Analytics Web Application** across multiple environments.

---

## 🎯 Option 1: Standalone Executable JAR (Easiest & Cross-Platform)

The application has been compiled and bundled into a standalone executable JAR file: `skill-analytics.jar`.

### Steps:
1. Ensure Java (JRE 17, 21, or 25) is installed.
2. Open terminal in the project directory:
   ```bash
   cd skill_progress_analytics
   ```
3. Run the JAR file:
   ```bash
   java -jar skill-analytics.jar
   ```
4. Or on custom port (e.g. 9000):
   ```bash
   java -jar skill-analytics.jar 9000
   ```
5. Open your browser at: **`http://localhost:8080`**

---

## 🐳 Option 2: Docker Container Deployment (Recommended for Cloud)

A multi-stage `Dockerfile` and `docker-compose.yml` are included in the repository.

### Steps:
1. **Build Docker Image:**
   ```bash
   docker build -t simats-skill-analytics .
   ```
2. **Run the Container:**
   ```bash
   docker run -d -p 8080:8080 --name skill-app simats-skill-analytics
   ```
3. **Or run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```
4. Access at **`http://localhost:8080`** or **`http://<SERVER_IP>:8080`**.

---

## ☁️ Option 3: Free Cloud Hosting (Render / Railway / Koyeb)

You can host this project online with a public HTTPS URL (`https://your-app.onrender.com`) for free.

### Steps for Render.com (Free Web Service):
1. Push your project folder to a GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Skill Progress Analytics"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<repo-name>.git
   git push -u origin main
   ```
2. Go to **[https://render.com](https://render.com)** and Sign Up / Log In.
3. Click **New +** $\to$ **Web Service**.
4. Connect your GitHub repository.
5. In the settings:
   - **Environment:** `Docker` (Render will automatically detect the `Dockerfile`)
   - **Plan:** Free
6. Click **Deploy Web Service**.
7. Render will automatically build the container and provide you with a live HTTPS URL!

---

## 🏫 Option 4: College Presentation / Local LAN Deployment

To demonstrate the application to your professors or evaluators on other laptops/mobiles connected to the same Wi-Fi or College LAN:

1. Find your laptop's local IP address:
   - Windows: Open PowerShell and run `ipconfig` (Look for `IPv4 Address`, e.g. `192.168.1.45`).
2. Start the server:
   ```powershell
   .\run.ps1
   ```
3. Share the URL with teachers or classmates on the same Wi-Fi:
   ```
   http://192.168.1.45:8080
   ```
   *(They can open this URL directly from their phones or laptops to test your application!)*

---

## 🖥️ Option 5: Linux / Cloud VPS Deployment (AWS EC2 / DigitalOcean / Ubuntu)

To run permanently in the background as a Linux `systemd` service:

1. Transfer the `skill_progress_analytics` directory to `/var/www/skill_progress_analytics`.
2. Create a systemd service file:
   ```bash
   sudo nano /etc/systemd/system/skill-analytics.service
   ```
3. Paste the configuration:
   ```ini
   [Unit]
   Description=SIMATS Skill Progress Analytics Web Application
   After=network.target

   [Service]
   User=ubuntu
   WorkingDirectory=/var/www/skill_progress_analytics
   ExecStart=/usr/bin/java -jar /var/www/skill_progress_analytics/skill-analytics.jar 8080
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
4. Enable and start the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable skill-analytics
   sudo systemctl start skill-analytics
   sudo systemctl status skill-analytics
   ```
