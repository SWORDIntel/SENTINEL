# Military-Grade Encryption API and VPN
An API example that uses military-grade encryption by implementing Perfect Forward Secrecy (PFS) and AES-256 (Advanced Encryption Standard) encryption, with ephemeral session keys.
<br>
Can be used as a Virtual Private Network (VPN), as well as an API.

## What is Perfect Forward Secrecy (PFS)?:
Perfect forward secrecy (PFS), also known as forward secrecy, is a cryptographic feature found in certain key-agreement protocols and underpins technologies like Virtual Private Networks (VPNs), etc. 
#### Why use PFS?:
It provides assurances that even if long-term secrets used during session key exchange are compromised, the communications or secrets (like passwords, encryption keys, etc.) themselves won’t be compromised, as they are ever-changing.
<br></br>
It's also an International Standard used by major organizations like:
1. VPN providers (Like NordVPN, McAfee, etc.)
2. Banking institutions (Like Bank Of China, Capitec Bank, Chase Bank, Wells Fargo, ABSA Bank, Royal Bank of Canada, FNB, Citibank, etc.)
3. Social media and email platforms (Like Twitter, Gmail, WhatsApp, Facebook, Instagram, Microsoft Outlook)
4. Governmental organizations (Like the CIA/FBI, The USA's Department of Defence (DoD) A.K.A The Pentagon, etc.)
5. Search engines (Google and Bing)
6. Security Software providers (Like CrowdStrike, FortiNet, McAfee, etc.)

#### How does PFS work, and what are the benefits of using it?:
1. Unique Session Keys:
   * PFS generates a unique private encryption key for each session. This means that even if one session key is compromised, it won’t affect other sessions. <br> So, if an attacker snoops on your messages today and steals your encryption keys, they still wont be able to decrypt your messages tomorrow or in a year, etc.
   * Basically: (Thinking about it like a WhatsApp chat) If a hacker steals a key to decrypt a private message, they can only decrypt 1 specific message, and not the entire chat history or future messages.
2. Past and Future Security:
   * Encrypted communications from the past/future cannot be retrieved and decrypted, even if the attacker stole network traffic for years (e.g., via a man-in-the-middle/on-path attack) because the encryption and session keys are ever-changing.
3. Less info leaked during breaches:
   * By protecting past communication, PFS reduces the motivation for attackers to compromise/target keys, and also results in less information leaks during security breaches, as the scope of unauthorized-access is limited.


## Special Notes:
1. No encryption method is perfect, and - whether it be memory/speed, interoperability, etc. - each one has its own concerns, flaws, strengths and intended use-case.
2. Any form of encryption is only as strong as your implementation of it. e.g. using AES-256 incorrectly does not give you the same security as someone that's used it correctly. The security depends on your implementation of it.
3. This project is still a Work In Progress (WIP). I will update this note once it has been completed.
4. There is an API-client already included in this repo, within the "API Client" folder - you can find it [here](https://github.com/Cyber-Finn/Military-Grade-Security-API/tree/main/API%20Client).

## What is PKI?
Public Key Infrastructure (PKI) allows us to securely exchange symmetric keys (more on this below). 
<br>
It also allows us to ensure that the destination we're sending to, is actually who they claim to be, and vice versa.

### Why is PKI important?
Symmetric keys are used to both encrypt and decrypt data. e.g. If I send you an encrypted message (Saying "hello, world!"), and the key, you would be able to decrypt the message (and get "hello, world!").
<br>
Unfortunately, cyber-criminals are smart, and target key-exchanges in hopes of stealing keys to snoop on messages or impersonate users. 
<br>
If (in our scenario above) a hacker were to intercept our message and steal our key, they would also get "hello, world!".
<br>
Compromised Key Exchanges are critical when confidential info (Like doctors' patient files, bank account info, etc.) is to be transmitted, because we want ONLY the Sender and intended Receiver to be able to read/edit the message.

### How does PKI work?
Basically, a service provider of some sort would host their website/API for the world to use. They would then generate or buy a "certificate" for this site. 
<br>
This certificate contains both a public key (which we - and anyone else - can actually publicly see), and a private/secret key (Which should never be shared with the outside world).
<br>
We (or our internet browsers) would use this public key to encrypt data that we want to "hide" from potential attackers, and send it off to the API/Site.
<br>
Once the message lands on the destination API/Site, that server would then use the Private/Secret key (Which only it, in the entire world, knows) to decrypt the message

### How is that different to our scenario from before?
In our scenario (using regular symmetric encryption):
* I sent you a message saying "hello, world!" and the key I used to encrypt the message. The hacker intercepted this message and changed it to say "you suck!". You got the message, and now feel offended!

Using PKI:
- I create a message saying "hello, world!", encrypt it with your PKI key, and send it to you. The hacker intercepts the message, but can't decrypt it, because you're the only one in the entire world with the private/decryption key.
<br>
If the hacker sends the message on to you, you'll still get the original message. If not, our secret message will be safe, because they can never decrypt it to see what it says.

# If PKI is so secure, why not just use it for everything?:
Because there's a limit to how much info you can securely send to any remote API using their RSA (PKI) keys. 
<br>
The keyspace is always limited for RSA keys -> this is because we trade "having ultimate security", for "size of data we can actually secure". 
<br>
A 2048-bit (global standard) RSA key has a keyspace of (2^{2048}), so we can basically (depending on padding) only encrypt between 214~245 bytes/characters (would be 256 bytes, but padding is used, so we lose space).
<br>
This makes sending large volumes of data, securely, completely impossible with the public key. 

## So how do we get around this issue?
Most websites/APIs combat this by having massive (and expensive) keys to allow users to encrypt more data (Your browser automatically does this for you on most sites), 
<br>
but this is still not enough for big data (MB/GB/TB of text, audio, video, etc.) and can be expensive, as some certs can cost upwards of $3K (USD).
<br>
This API (and the system I've created [including the API-client]) allows us to use a standard 2048-bit public asymmetric RSA key, to bypass the massive limitation on how much data we can send, 
<br>
while providing maximum security and establishing a secure exchange of symmetric keys, with ephemeral session keys to prevent against on-path/man-in-the-middle attacks.
