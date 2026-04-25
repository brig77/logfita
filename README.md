# Logfita

Logfita is a macOS tool used to track the work hours logged in the macOS Calendar. The main idea is to use the mac OS calendar to log work hours and then use this tool to check if the amount of hours is correct and generate time reports based on configurable rules.


---

ATTENTION: this is a project for personal use that I am making public to help anyone out there with the same need and for my own record keeping. I only work on this project sometimes. So any bug or improvement suggestion might not be addressed soon.

---

## Build and Run

To compile and launch the Logfita application, simply use the provided shell script:

1. Open your terminal and navigate to the project directory.
2. Run the build script to compile the application bundle:
   ```bash
   ./build.sh
   ```
3. Once built, you can run the app directly via:
   ```bash
   open Logfita.app
   ```

A Logfita icon will appear in your Mac's top menu bar. Click the icon, then select **Settings...** (`Cmd + ,`) to define your target hours and select which calendars to track.
