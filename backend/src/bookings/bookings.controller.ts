import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(
    private readonly bookingsService: BookingsService,
  ) {}

  @Post()
  create(
    @Req() request: Request,
    @Body() dto: CreateBookingDto,
  ) {
    const payload = (request as any).user;

    return this.bookingsService.create(
      payload.sub,
      dto,
    );
  }

  @Get('me')
  findMine(
    @Req() request: Request,
  ) {
    const payload = (request as any).user;

    return this.bookingsService.findMine(
      payload.sub,
    );
  }

  @Patch(':id/cancel')
cancel(
  @Req() request: Request,
  @Param('id') id: string,
) {
  const payload = (request as any).user;

  return this.bookingsService.cancelMine(
    id,
    payload.sub,
  );
}

  @Get(':id')
  findOne(
    @Req() request: Request,
    @Param('id') id: string,
  ) {
    const payload = (request as any).user;

    return this.bookingsService.findOne(
      id,
      payload.sub,
    );
  }
}