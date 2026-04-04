import { createApp } from './app';
import { env } from './config/env';
import { connectMongoDB } from './db/mongodb';
import { connectRedis } from './db/redis';

async function startServer() {
  await connectMongoDB();
  await connectRedis();

  const app = createApp();

  app.listen(env.port, env.host, () => {
    console.log(`Luminous backend listening on http://${env.host}:${env.port}`);
  });
}

startServer().catch(err => {
  console.error('Failed to start server:', err);
});
