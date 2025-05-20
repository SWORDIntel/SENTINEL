<p align="center">
  <img src="https://i.imgur.com/0DGuMrJ.png" alt="SSH Checker Banner" />
</p>

<h1 align="center">SSH Checker</h1>

<h2 align="center">Overview</h2>

<p align="center">
Welcome to SSH Checker! This lightweight Python script is designed to help you verify the availability and responsiveness of SSH servers. Whether you’re a system administrator or a security professional, this tool will make managing multiple SSH servers a breeze. With SSH Checker, you can quickly check the status of your SSH services and ensure everything is running smoothly.
</p>

<h2 align="center">Features</h2>

<p align="center">
Fast Checking: The script uses threading to rapidly check the status of multiple SSH servers simultaneously, saving you time.
</p>

<p align="center">
Error Handling: It catches connection errors and displays appropriate messages, so you know exactly what’s going on.
</p>

<p align="center">
Customizable: Feel free to modify the script to suit your specific needs—it’s flexible and user-friendly.
</p>

<p align="center">
ASCII Art Banner: Enjoy a visually appealing banner that greets you when you start the script.
</p>

<h2 align="center">Getting Started</h2>

<h2 align="center">Prerequisites</h2>

<p align="center">
Before you dive in, make sure you have the following:
</p>

<ul align="center">
  <li>Python 3.x installed on your machine</li>
  <li>The required library paramiko</li>
</ul>

<h2 align="center">Installation</h2>

<p align="center">
Let’s get SSH Checker up and running.
</p>

<p align="center">
Clone the repository:
</p>

<pre align="center">
git clone https://github.com/SleepTheGod/SSH-Checker.git
</pre>

<p align="center">
Change to the project directory:
</p>

<pre align="center">
cd SSH-Checker
</pre>

<p align="center">
Install the required dependencies:
</p>

<pre align="center">
pip install paramiko
</pre>

<h2 align="center">Usage</h2>

<p align="center">
Running the script is simple! Just use the following command:
</p>

<pre align="center">
python ssh_checker.py &lt;host_file.txt&gt;
</pre>

<p align="center">
Make sure to replace &lt;host_file.txt&gt; with the path to your text file that contains the list of SSH servers you want to check (one server per line).
</p>

<h2 align="center">Example</h2>

<p align="center">
Here’s a quick example to get you started:
</p>

<p align="center">
Create a file named <code>hosts.txt</code> with the following content:
</p>

<pre align="center">
192.168.1.1
192.168.1.2
example.com
</pre>

<p align="center">
Run the SSH Checker script with:
</p>

<pre align="center">
python ssh_checker.py hosts.txt
</pre>

<p align="center">
And that’s it! You’re all set to start checking your SSH servers. Enjoy using SSH Checker and feel free to modify it to better fit your needs. Happy checking!
</p>
