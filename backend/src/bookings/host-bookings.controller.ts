import {
  Controller,
  Get,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { BookingsService } from './bookings.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostGuard } from '../properties/host.guard';

@Controller('host/bookings')
@UseGuards(JwtAuthGuard, HostGuard)
export class HostBookingsController {
  constructor(
    private readonly bookingsService: BookingsService,
  ) {}

  @Get()
  findAll(
    @Req() request: Request,
  ) {
    const payload = (request as any).user;

    return this.bookingsService.findForHost(
      payload.sub,
    );
  }

  @Get(':id')
  findOne(
    @Req() request: Request,
    @Param('id') id: string,
  ) {
    const payload = (request as any).user;

    return this.bookingsService.findOneForHost(
      id,
      payload.sub,
    );
  }
}