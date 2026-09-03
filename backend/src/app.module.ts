import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { PrismaModule } from './prisma/prisma.module';
import { HealthController } from './health/health.controller';
import { BookingsModule } from './bookings/bookings.module';

import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PropertiesModule } from './properties/properties.module';
import { PaymentsModule } from './payments/payments.module';
import { MessagingModule } from './messaging/messaging.module';
import { ReviewsModule } from './reviews/reviews.module';



@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    PrismaModule,
    AuthModule,
    UsersModule,
    PropertiesModule,
    BookingsModule,
    PaymentsModule,
    MessagingModule,
    ReviewsModule,
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