import os
import shutil

def main():
    print("Building Flutter web app...")
    # This script assumes build\web is already compiled or compiles it.
    web_dir = os.path.join("build", "web")
    
    if not os.path.exists(web_dir):
        print(f"Error: Build directory {web_dir} does not exist. Run 'flutter build web' first.")
        return

    index_path = os.path.join(web_dir, "index.html")
    app_path = os.path.join(web_dir, "app.html")

    # Rename original index.html to app.html if app.html does not exist yet
    # Or overwrite app.html with current index.html if we are rebuilding
    if os.path.exists(index_path):
        print("Renaming index.html to app.html...")
        if os.path.exists(app_path):
            os.remove(app_path)
        os.rename(index_path, app_path)
    
    # Write the new index.html with the device mockup
    simulator_html = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Make Fit - Live Simulator</title>
  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      --dark-navy: #080918;
      --neon-purple: #9D4EDD;
      --deep-purple: #6B1D9F;
      --neon-pink: #E01E79;
      --text-white: #ffffff;
      --text-grey: #8B8C9E;
      --glass-grad: linear-gradient(135deg, rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0.01));
      --glass-border: 1px solid rgba(255, 255, 255, 0.08);
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Outfit', sans-serif;
    }

    html, body {
      height: 100%;
      width: 100%;
      margin: 0;
      padding: 0;
    }

    body {
      background-color: #03040B;
      color: #ffffff;
      display: flex;
      justify-content: center;
      align-items: center;
      overflow: hidden;
      background-image: radial-gradient(circle at top right, rgba(157, 78, 221, 0.12), transparent 600px),
                        radial-gradient(circle at bottom left, rgba(224, 30, 121, 0.08), transparent 600px);
    }

    /* Right Smartphone Frame Container */
    .phone-wrapper {
      position: relative;
      width: 355px;
      height: 720px;
      background: #000000;
      border-radius: 54px;
      padding: 12px;
      box-shadow: 0 25px 60px rgba(0, 0, 0, 0.8), 0 0 0 4px #2b2b2b, 0 0 0 12px #151515;
      overflow: hidden;
    }

    /* Notch */
    .phone-notch {
      position: absolute;
      top: 12px;
      left: 50%;
      transform: translateX(-50%);
      width: 130px;
      height: 30px;
      background: #000000;
      border-bottom-left-radius: 20px;
      border-bottom-right-radius: 20px;
      z-index: 100;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .phone-notch::before {
      content: '';
      width: 40px;
      height: 4px;
      background: #1c1c1c;
      border-radius: 2px;
    }

    /* Phone Screen Container */
    .phone-screen {
      width: 100%;
      height: 100%;
      border-radius: 42px;
      background-color: var(--dark-navy);
      overflow: hidden;
      position: relative;
    }

    /* Phone Status Bar */
    .status-bar {
      height: 38px;
      padding: 14px 28px 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 11px;
      font-weight: 600;
      color: #ffffff;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      z-index: 90;
      pointer-events: none;
    }

    .status-icons {
      display: flex;
      gap: 6px;
      align-items: center;
    }

    .battery-icon {
      width: 18px;
      height: 10px;
      border: 1px solid #ffffff;
      border-radius: 3px;
      padding: 1px;
      position: relative;
    }

    .battery-level {
      width: 85%;
      height: 100%;
      background: #ffffff;
      border-radius: 1px;
    }

    /* Iframe loading Flutter web */
    iframe {
      width: 100%;
      height: 100%;
      border: none;
      background: transparent;
      padding-top: 38px; /* Offset status bar */
    }

    /* Mobile responsive override */
    @media (max-width: 1023px) {
      body {
        background-color: var(--dark-navy);
      }
      .phone-wrapper {
        width: 100%;
        height: 100%;
        height: 100dvh;
        border-radius: 0;
        padding: 0;
        box-shadow: none;
      }
      .phone-notch, .status-bar {
        display: none;
      }
      iframe {
        padding-top: 0;
      }
    }
  </style>
</head>
<body>
  <div class="phone-wrapper">
    <div class="phone-notch"></div>
    <div class="phone-screen">
      <div class="status-bar">
        <span>9:41</span>
        <div class="status-icons">
          <span>5G</span>
          <div class="battery-icon">
            <div class="battery-level"></div>
          </div>
        </div>
      </div>
      <iframe src="app.html"></iframe>
    </div>
  </div>
</body>"""

    print("Writing simulator index.html...")
    with open(index_path, "w", encoding="utf-8") as f:
        f.write(simulator_html)

    print("Done wrapping web build!")

if __name__ == "__main__":
    main()
