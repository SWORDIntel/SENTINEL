## Purpose

I found this API, [FBI most wanted](https://www.fbi.gov/wanted/api), and thought it would be interesting to create a FBI bounty site. The API is a bit messy, misspelled keys (i.e. "legat_names" is most likely "legal_names"), a lot of the images don't work so you'll see (400s) in the network tab.

I feel a bit dedicated to it, the FBI can use a hand with better UI & UX for the most wanted people in the world. Any PRs are welcome.

Techstack: [ NextJS, TypeScript, JavaScript, hosted on Vercel ]

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `pages/index.tsx`. The page auto-updates as you edit the file.

[API routes](https://nextjs.org/docs/api-routes/introduction) can be accessed on [http://localhost:3000/api/hello](http://localhost:3000/api/hello). This endpoint can be edited in `pages/api/hello.ts`.

The `pages/api` directory is mapped to `/api/*`. Files in this directory are treated as [API routes](https://nextjs.org/docs/api-routes/introduction) instead of React pages.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## TODOs

- [ ] Fix bounty regex to add strings [ 'million']
- [ ] Add an image zoom utility or create own
- [ ] Utilize UI lib (chakra)
- [ ] Add a hero image for top bounty on each page
- [ ] Sorting (allow sort by bounty, by date, etc)

## Nice to haves
- Use NextJS API or Golang to redo the API
