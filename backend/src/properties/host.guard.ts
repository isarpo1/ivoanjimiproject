import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { UsersService } from '../users/users.service';

@Injectable()
export class HostGuard implements CanActivate {
  constructor(private readonly usersService: UsersService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    const payload = request.user;

    if (!payload?.sub) {
      throw new UnauthorizedException('Authentication required');
    }

    const user = await this.usersService.findById(payload.sub);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (!user.isHost) {
      throw new ForbiddenException(
        'You must activate a host account to manage properties',
      );
    }

    return true;
  }
}