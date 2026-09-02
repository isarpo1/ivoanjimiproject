import {
  Controller,
  Get,
  NotFoundException,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // Get the currently logged-in user's profile
  @UseGuards(JwtAuthGuard)
  @Get('me')
  async getMe(@Req() request: Request) {
    const payload = (request as any).user;

    const user = await this.usersService.findById(payload.sub);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isHost: user.isHost,
      isVerified: user.isVerified,
      profilePhotoUrl: user.profilePhotoUrl,
      createdAt: user.createdAt,
    };
  }

  // Allow a logged-in user to activate host/lister mode
  @UseGuards(JwtAuthGuard)
  @Patch('me/become-host')
  async becomeHost(@Req() request: Request) {
    const payload = (request as any).user;

    const user = await this.usersService.becomeHost(payload.sub);

    return {
      message: 'Host account activated',
      user: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        isHost: user.isHost,
      },
    };
  }
}