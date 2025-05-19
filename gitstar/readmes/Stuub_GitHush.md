# GitHush: <i>Who needs Git Blame?</i> 

![image](https://github.com/user-attachments/assets/b05db2de-8af1-47f8-b782-224e29e2fcff)

## Bottom Line Up front (BLUF)

Setting our bait in the Github Events REST API to wait for the secrets to roll in :D 

<i>Yes, it's that easy...</i>

## How Do I Use It?

```bash
git clone https://github.com/Stuub/GitHush && cd GitHush
pip3 install -r requirements.txt
python3 GitHush.py --github-token <Your_Access_Token>
# OR
python3 GitHush.py  # Falls back to environment variable for personal access token
```

## Verbatim

GitHush leverages the [GitHub Events API](https://docs.github.com/en/rest/activity/events?apiVersion=2022-11-28) to passively monitor public repository activity for inadvertent exposure of secrets and credentials in near real-time. The tool automates the detection of sensitive information disclosures using targeted regular expression (regex) patterns, fetching content from commits, pull requests, and database files.

### How it works

- Polls https://api.github.com/events using a personal access token (PAT), respecting GitHub’s unauthenticated rate limit of 60 req/hr or 5,000 req/hr with a token.

- Parses PushEvent and PullRequestEvent types, extracting commit and file URLs from payloads.

- Fetches file content or downloads .db files for SQLite inspection.

- Uses a curated set of regex signatures to detect:

      AWS Auth Keys
      JWT Tokens
      OpenAI API Keys
      SSH Pub & Private keys
      Plaintext passwords
      Email Addresses
      OIDC Tokens
      Sensitive files (wp-config.php, phpmailer.php, .env, etc.)
      SMTP Credentials
      Database connection strings + extracting db info

- Dumps output to JSONL with commit SHA, repo info, file names, and matched secrets.


### Notable Features

  🔍 High-Signal Filtering: Matches include context-based patterns (e.g., define('DB_USER'...) or $mail->Password = ...)

  🗄️ DB-Aware Scanning: Discovered & Extracted DB files are parsed, queried, and analysed dynamically.

  🧪 Regex Library: Includes patterns for over 20 common credential formats (feel free to send me more >:D).
  
  📦 JSONL Logging: Structured output allows easy integration with threat intelligence pipelines or SIEMs.

  🧰 Language/Framework-Aware: Recognizes secrets in PHP, Python, Node.js, CI/CD files, etc.


## Proof of Concept (PoC)

### Email Addresses

![githushEmail](https://github.com/user-attachments/assets/095b4b66-2dcd-405f-902b-e9f7f2ad8ce6)


### Passwords

![GitHushPassword](https://github.com/user-attachments/assets/761ec812-9a40-42c5-973d-89e57f57d1dd)


### SSH Keys

![image](https://github.com/user-attachments/assets/0ba3f49d-bd44-435b-a9a9-a8dd2430c0d2)


### API Keys

![githushOpenAI](https://github.com/user-attachments/assets/c568cd74-cc48-40aa-8abe-8154dd437723)


### Database Connection Strings

![GithushSQLDB](https://github.com/user-attachments/assets/51b74a11-40f3-410d-841d-79abef8c48e2)


## Contributions Welcome!

If you have any suggestions, regex ideas, or issues, feel free to make a PR or Issue and I'll be sure to check it out.

# Otherwise, my socials:

### - [X](https://x.com/stuub_)

### - https://stuub.dev

### - [LinkedIn](https://www.linkedin.com/in/stuart-beck-4a69051a4/)

### - [Coffee!](https://buymeacoffee.com/stuub)

