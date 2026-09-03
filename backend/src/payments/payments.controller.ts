import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateMockPaymentDto } from './dto/create-mock-payment.dto';
import { PaymentsService } from './payments.service';

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
  ) {}

  @Post('mock/initialize')
  initialize(
    @Req() request: Request,
    @Body() dto: CreateMockPaymentDto,
  ) {
    const payload = (request as any).user;

    return this.paymentsService.initializeMockPayment(
      dto.bookingId,
      payload.sub,
    );
  }

  @Post(':id/mock-success')
  simulateSuccess(
    @Req() request: Request,
    @Param('id') id: string,
  ) {
    const payload = (request as any).user;

    return this.paymentsService.simulateSuccess(
      id,
      payload.sub,
    );
  }

  @Get('me')
  findMine(
    @Req() request: Request,
  ) {
    const payload = (request as any).user;

    return this.paymentsService.findMine(
      payload.sub,
    );
  }
}