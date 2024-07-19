import tkinter as tk
from tkinter import messagebox
from datetime import datetime
import time
import threading
import pafy
import vlc

# Function to play YouTube song using VLC
def play_song(youtube_url):
    # Extract the best available audio stream from the YouTube video
    video = pafy.new(youtube_url)
    best = video.getbestaudio()
    playurl = best.url
    
    # Create VLC player instance and media player
    Instance = vlc.Instance()
    player = Instance.media_player_new()
    Media = Instance.media_new(playurl)
    Media.get_mrl()
    player.set_media(Media)
    player.play()

# Function to check the alarm time
def check_alarm(alarm_time, youtube_url):
    while True:
        # Get current time in HH:MM format
        current_time = datetime.now().strftime("%H:%M")
        if current_time == alarm_time:
            play_song(youtube_url)
            break
        time.sleep(1)

# Function to set the alarm
def set_alarm():
    # Get alarm time and YouTube URL from user input
    alarm_time = f"{hour.get()}:{minute.get()}"
    youtube_url = youtube_link.get()
    
    # Display confirmation message
    messagebox.showinfo("Alarm Set", f"Alarm set for {alarm_time} with song {youtube_url}")
    
    # Start a new thread to check the alarm
    threading.Thread(target=check_alarm, args=(alarm_time, youtube_url)).start()

# GUI setup
root = tk.Tk()
root.title("Alarm Clock")

# Add labels and entry fields for time and YouTube URL
tk.Label(root, text="Set Time (HH:MM)").pack()
hour = tk.Entry(root, width=3)
hour.pack(side=tk.LEFT)
minute = tk.Entry(root, width=3)
minute.pack(side=tk.LEFT)

tk.Label(root, text="YouTube Link").pack()
youtube_link = tk.Entry(root, width=50)
youtube_link.pack()

# Add button to set the alarm
set_button = tk.Button(root, text="Set Alarm", command=set_alarm)
set_button.pack()

# Start the main event loop
root.mainloop()
