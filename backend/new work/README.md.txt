Fitness App Backend
This project is a simple backend for a fitness application built with Node.js and Express. It's designed to accept user details (weight, height, etc.) and then allow the user to upload a video for a fitness assessment.

Project Structure
server.js: The main entry point for the application. It starts the server and sets up all the middleware.

package.json: Defines the project dependencies and scripts.

routes/: Contains the API route definitions.

userRoutes.js: Handles all API logic for user details and video uploads.

public/: Contains static front-end files that are served to the user.

index.html: The initial form to collect user data.

video.html: The page where the user uploads their fitness test video.

uploads/: This directory is automatically created and will store all the videos uploaded by users.

How to Run the Application
Prerequisites
You must have Node.js installed on your computer.

Steps
Open a terminal or command prompt.

Navigate to the project directory:

cd path/to/your/desktop/new work

Install the necessary dependencies:
This command reads the package.json file and installs Express and Multer.

npm install

Start the server:

npm start

Access the application:
You will see a message in the terminal: Server is running on http://localhost:3000.
Open your web browser and go to this address:
http://localhost:3000

How It Works
When you visit the homepage, index.html is served. You can fill in your details and click "Proceed to Fitness Test".

The form data is sent via a POST request to the /api/details endpoint. The backend server receives this data, logs it to the console, and then redirects you to /video.html.

On the video upload page, you can select a video file.

When you click "Upload and Finish", the video is sent via a POST request to the /api/upload endpoint.

The multer middleware on the server intercepts this request, saves the video file to the uploads/ directory with a unique name, and then displays a success message.