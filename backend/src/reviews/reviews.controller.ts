import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReviewsService } from './reviews.service';

@Controller()
export class ReviewsController {
  constructor(
    private readonly reviewsService: ReviewsService,
  ) {}

  @Post('reviews')
  @UseGuards(JwtAuthGuard)
  create(
    @Req() request: Request,
    @Body() dto: CreateReviewDto,
  ) {
    const payload = (request as any).user;

    return this.reviewsService.create(
      payload.sub,
      dto,
    );
  }

  @Get('properties/:propertyId/reviews')
  findPropertyReviews(
    @Param(
      'propertyId',
      new ParseUUIDPipe({ version: '4' }),
    )
    propertyId: string,
  ) {
    return this.reviewsService.findPropertyReviews(
      propertyId,
    );
  }

  @Get('users/me/reviews')
  @UseGuards(JwtAuthGuard)
  findMine(
    @Req() request: Request,
  ) {
    const payload = (request as any).user;

    return this.reviewsService.findMine(
      payload.sub,
    );
  }
}