import { Module } from '@nestjs/common';

import { PropertiesModule } from '../properties/properties.module';
import { UsersModule } from '../users/users.module';

import { BookingsController } from './bookings.controller';
import { BookingsService } from './bookings.service';
import { HostBookingsController } from './host-bookings.controller';

@Module({
  imports: [
    PropertiesModule,
    UsersModule,
  ],

  controllers: [
    BookingsController,
    HostBookingsController,
  ],

  providers: [
    BookingsService,
  ],

  exports: [
    BookingsService,
  ],
})
export class BookingsModule {}