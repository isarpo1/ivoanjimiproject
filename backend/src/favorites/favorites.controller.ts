import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SaveStayDto } from './dto/save-stay.dto';
import { FavoritesService } from './favorites.service';

@Controller('favorites')
@UseGuards(JwtAuthGuard)
export class FavoritesController {
  constructor(
    private readonly favoritesService: FavoritesService,
  ) {}

  @Get('me')
  findMine(@Req() request: Request) {
    const payload = (request as any).user;

    return this.favoritesService.findMine(payload.sub);
  }

  @Post()
  save(
    @Req() request: Request,
    @Body() dto: SaveStayDto,
  ) {
    const payload = (request as any).user;

    return this.favoritesService.save(
      payload.sub,
      dto,
    );
  }

  @Delete(':propertyId')
  remove(
    @Req() request: Request,
    @Param(
      'propertyId',
      new ParseUUIDPipe({ version: '4' }),
    )
    propertyId: string,
  ) {
    const payload = (request as any).user;

    return this.favoritesService.remove(
      payload.sub,
      propertyId,
    );
  }
}
