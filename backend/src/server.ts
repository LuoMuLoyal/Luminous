import { createApp } from './app';
import { env } from './config/env';
import { connectMongoDB } from './db/mongodb';

async function startServer() {
  await connectMongoDB();

  const app = createApp();

  app.listen(env.port, () => {
    console.log(`Luminous backend listening on http://127.0.0.1:${env.port}`);
  });
}

startServer().catch(err => {
  console.error('Failed to start server:', err);
});

