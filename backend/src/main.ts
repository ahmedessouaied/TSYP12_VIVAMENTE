import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS for requests coming from port 5174
  app.enableCors({
    origin: '*',  // Allow requests from this specific origin
    methods: 'GET,POST,PUT,DELETE,PATCH',  // Allow specific HTTP methods
    allowedHeaders: 'Content-Type, Authorization', // Allow specific headers
  });
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
