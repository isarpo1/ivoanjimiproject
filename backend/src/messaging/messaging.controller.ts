import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { MessagingService } from './messaging.service';

@Controller('conversations')
@UseGuards(JwtAuthGuard)
export class MessagingController {
  constructor(
    private readonly messagingService: MessagingService,
  ) {}

  @Post()
  create(
    @Req() request: Request,
    @Body() dto: CreateConversationDto,
  ) {
    const payload = (request as any).user;

    return this.messagingService.createConversation(
      payload.sub,
      dto,
    );
  }

  @Get('me')
  findMine(
    @Req() request: Request,
  ) {
    const payload = (request as any).user;

    return this.messagingService.findMine(
      payload.sub,
    );
  }

  @Get(':id')
  findOne(
    @Req() request: Request,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    const payload = (request as any).user;

    return this.messagingService.findOne(
      id,
      payload.sub,
    );
  }

  @Get(':id/messages')
  findMessages(
    @Req() request: Request,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    const payload = (request as any).user;

    return this.messagingService.findMessages(
      id,
      payload.sub,
    );
  }

  @Post(':id/messages')
  sendMessage(
    @Req() request: Request,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: SendMessageDto,
  ) {
    const payload = (request as any).user;

    return this.messagingService.sendMessage(
      id,
      payload.sub,
      dto,
    );
  }

  @Patch(':id/read')
  markRead(
    @Req() request: Request,
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
  ) {
    const payload = (request as any).user;

    return this.messagingService.markRead(
      id,
      payload.sub,
    );
  }
}