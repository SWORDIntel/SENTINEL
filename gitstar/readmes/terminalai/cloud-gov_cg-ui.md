# Cloud.gov UI prototype

This is a prototype for a future Cloud.gov user interface.

## Getting started with local development

### Step 1: Prepare your environment

#### Node

[Install node 20.x](https://nodejs.org/en/download/) on your machine. Check [`.nvmrc`](.nvmrc) for the app's current version.

#### ZScaler

If your environment uses ZScaler, you must make Node aware of your ZScaler certificate so you can install packages via npm. If ZScaler is not active in your environment, you may skip this part.

Output the certificate in pem format. Place the pem in a stable location you can refer to repeatedly.

```bash
security find-certificate -a -c zscaler -p > [path_to_cert]/zscaler_root_ca.pem
```

Edit a file that will execute when you open a new terminal session. For example, `~./zshrc` or `~./bashrc` or similar. Load the pem as a variable that Node will read:

```bash
export NODE_EXTRA_CA_CERTS=[path_to_cert]/zscaler_root_ca.pem
```

#### Dependencies

Open a new shell, clone this repository, and install the dependencies:

```bash
npm install
```

Next, [install the Cloud Foundry command line tool](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html). On mac, you can run:

```bash
brew install cloudfoundry/tap/cf-cli@8
```

### Step 2: Log into your Cloud.gov account

Ask a member of the Cloud.gov team to grant your user access to the cloud development environment. You may choose instead to use your regular (production) cloud.gov account, but be aware that __any actions you take in the app, such as deleting spaces or apps, will affect your cloud.gov applications and services.__

Once you have a development account, log into the CF CLI. Follow the prompts to authenticate:

```bash
# log into development
cf login -a api.dev.us-gov-west-1.aws-us-gov.cloud.gov --sso

# log into production (not recommended)
cf login -a api.fr.cloud.gov --sso
```

You do not need to target an organization or space.

### Step 3: Run a local user accounts and authentication (UAA) server

Users will need to authenticate through UAA in order to view the application. A real UAA flow can't be done locally, because UAA can't whitelist `localhost`. So in local development, we simulate authentication in two ways:

1) **By running a local UAA server** - This login flow provides fake `authsession` cookie data. The presence of this cookie is what allows you to visit authenticated pages when navigating the app.
2) **By setting CloudFoundry data in our environment file** - Because local UAA returns fake data, we need to obtain real CF credentials through the CF CLI and keep them in `.env.local`. This allows you to get real CloudFoundry API data. (Handled in steps 4 and 5.)

See the [uaa-docker README](uaa-docker/README.md) for set up instructions.

In another shell, start the UAA container:

```bash
cd uaa-docker
# follow instructions to build before running up
docker compose up
```

Use credentials found in `uaa-docker/uaa.yml` to log in.

### Step 4: Configure the application

Copy the example `.env.example.local` file. Do not check `.env.local` into source control.

```bash
cp .env.example.local .env.local
```

You do not need to change anything about this file for local development unless you logged into your production cloud.gov account during the previous step.

```bash
# change this line if you are using production
CF_API_URL=https://api.fr.cloud.gov/v3
```

For certain pages, you'll also need to set your `CF_USER_ID`. This is normally returned from UAA and placed in the `authsession` cookie, but when working locally, you'll need to obtain this from your CloudFoundry environment (like by running `cf curl '/v3/users'` or by running `cf oauth-token` and decoding the returned JWT token).

Note: the variable `CF_API_TOKEN` is not yet populated. That's okay! Continue to the next step to set it.

### Step 5: Run the app!

Start the app with the `dev-cf` command:

```bash
npm run dev-cf
```

This will fetch your local cloud foundry token from the CF CLI tool and use it to start the app, giving your user permission to access and manipulate cloud foundry resources through the UI.

Visit `localhost:3000` to check it out!

#### Troubleshooting and dev eccentricities

Due to developing locally against a "real" environment, we have to play by the rules of the CF CLI. This means that our token expires every 15 minutes or so, and we also need to reauthenticate every 24 hours.

The `dev-cf` command runs a token refresh every 14 and a half minutes, provided you're still authenticated. If you start getting 401 errors, reauthenticate with CF CLI and GSA PreProd as described in step 2, then restart your application to get a new token. 

### Step 6: Optional stretch goals

The above steps are enough to get most people up and running, but our app has more bells and whistles! Consider yourself good to go unless if you plan to do any of the following:

- running the test suite
- working on the logging in flow
- developing something related to user access information
- in need of a database

#### S3 user information

This application relies on an s3 bucket to pull information about a user's last access date and their account status (active vs inactive). This bucket is populated by the [uaa-bot](https://github.com/cloud-gov/uaa-bot) and is only available in the development environment. If access is not hooked up, you will simply see "no user information" in the UI.

Create a new service key for your targeted org and environment. Name the key something descriptive enough that you can identify it again. For example, `cg-ui-storage-key`.

```bash
cf create-service-key cg-ui-storage [name-of-your-key]
```

Pull down the key (this contains sensitive information):

```bash
cf service-key cg-ui-storage [name-of-your-key]
```

You are interested in these parts of the key:

```
{
  "access_key_id": "...",
  "bucket": "...",
  "region": "...",
  "secret_access_key": "..."
}
```

Copy the values into your `.env.local` file for the variables `S3_ACCESS_KEY_ID`, `S3_ACCESS_KEY_SECRET`, `S3_BUCKET`, AND `S3_REGION`.

You can keep the key around between development sessions, but you may wish to rotate it or delete it when you are no longer using it:

```bash
cf delete-service-key cg-ui-storage [name-of-your-key]
```

#### The database

Follow the steps in the [cgui-db-docker README](cgui-db-docker/README.md) to set up a postgres db in docker. This database is only a proof-of-concept for our application at the moment, but is needed if you will be running the full test suite.

Start the container (note, the command may be `docker-compose` on older installs):

```bash
cd cgui-db-docker
docker compose build
docker compose up
```


### Step 7: Testing

To run the entire unit test suite, you will need to start the docker database container:

```bash
cd cgui-db-docker
docker compose up
```

Run the suite:

```bash
npm test
```

To run test files matching certain text (one example):

```bash
npm test -- serverside
```

#### Integration testing

We have one test that runs against the s3 bucket to test that updates to the AWS libraries have not broken the connection. This test runs locally and is not part of the CI pipeline. To run this test, set up a local-only test environment file. This file should not be tracked in version control:

```bash
cp .env.test.example.local .env.test.local
```

Then, if you have not already, set up a [s3 service key](#s3-user-information). Copy the values into `.env.test.local`.  To run the test:

```bash
npm run test:integration
```

### Step 8: Committing

#### Preparing your code

You can optionally set up the repository with a pre-commit hook to scan files you have just staged for linting / prettifying:

```bash
npm run setup-precommit
```

If you prefer, you may run these utilities manually instead:

```bash
npm run lint

npm run format
# to alter files automatically
npm run format:fix
```

You may also wish to test that the next application is building before you commit and push:

```bash
npm run build
```

Eslint configurations are found in [.eslintrc.json](.eslintrc.json). Prettier configurations are found in [.prettierrc.json](.prettierrc.json).

#### Signing your commits

Cloud.gov requires any commits to this repo to be signed with a GPG key. [You will need to set up commit signing before the first time you contribute](https://docs.google.com/document/d/11UDxvfkhncyLEs-NUCniw2u54j4uQBqsR2SBiLYPUZc/edit) :closed_lock_with_key:.

#### Scanning for secrets

Cloud.gov requires that contributors have the [caulking tool](https://github.com/cloud-gov/caulking) installed and running on their machines. Follow the instructions to install caulking and confirm that `make audit` passes all checks.

## Step 9: Deploying

This application is deployed to the cloud.gov development environment automatically when changes are merged into the main branch. Deployment is managed via Concourse CI (see the `ci` directory).

See the developer documentation for instructions to [manually deploy the application](docs/dev-practices/manual-deploy.md).

## Team practices

### Working with USWDS

Our team keeps custom CSS/SASS to a minimum and takes a [utilities-first](https://designsystem.digital.gov/utilities/) approach.

Please see our [developer guidelines](docs/dev-practices/USWDS.md) about this approach, how USWDS is integrated into our application, and steps to take when upgrading.

### File conventions

We prioritize named imports, TypeScript, and Pascal Case component names throughout our application. Read more about our [file conventions](docs/dev-practices/file-conventions.md).

### Application structure

Next.js has few opinions about how to structure applications. We have chosen to use an MVC (Model View Controller)-like pattern.

See our [architecture](docs/dev-practices/architecture.md) documentation for information about each of the layers and how we are using them.

### Architectural decision records and explainers

We keep Architectural Decision Records (ADRs) to explain decisions we have made and alternatives we considered. You may find them in the [adrs](docs/adr/README.md) directory.

When we come across concepts that are initially confusing or required significant time to understand, we have created [explainers](docs/explainers/README.md) to capture our newly acquired knowledge.

## Updating dependencies

### Updating Node

The Node version should be updated in the following places:

1. [.nvmrc](.nvmrc) which controls the version for cloud builds
1. [Github workflow containers](.github/workflows/pull-request.yml) `NODE_VERSION` which controls the version in Github action containers
1. [package.json](package.json) under `engines` to specify which version(s) our app works with
1. [Concourse docker-compose](ci/docker/docker-compose.yml) and [pipeline](ci/pipeline.yml)

### Updating USWDS

See the [USWDS](docs/dev-practices/USWDS.md) documentation for more information about how to update USWDS and its assets.
