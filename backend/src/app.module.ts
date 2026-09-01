import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { PrismaModule } from './prisma/prisma.module';
import { HealthController } from './health/health.controller';

import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    PrismaModule,
    AuthModule,
    UsersModule,
  ],

  controllers: [
    AppController,
    HealthController,
  ],

  providers: [
    AppService,
  ],
})
export class AppModule {}