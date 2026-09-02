import { Module } from '@nestjs/common';

import { UsersModule } from '../users/users.module';

import { PropertiesController } from './properties.controller';
import { PropertiesService } from './properties.service';
import { HostGuard } from './host.guard';
import { AmenitiesController } from './amenities.controller';
import { PublicPropertiesController } from './public-properties.controller';
import { PublicAmenitiesController } from './public-amenities.controller';

@Module({
  imports: [
    UsersModule,
  ],

  controllers: [
    PropertiesController,
    AmenitiesController,
    PublicPropertiesController,
    PublicAmenitiesController,
  ],

  providers: [
    PropertiesService,
    HostGuard,
  ],

  exports: [
    PropertiesService,
    HostGuard,
  ],
})
export class PropertiesModule {}