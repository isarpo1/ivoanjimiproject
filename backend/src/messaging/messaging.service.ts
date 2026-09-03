import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';

@Injectable()
export class MessagingService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async createConversation(
    userId: string,
    dto: CreateConversationDto,
  ) {
    const property =
      await this.prisma.property.findUnique({
        where: {
          id: dto.propertyId,
        },

        select: {
          id: true,
          hostId: true,
          status: true,
          title: true,
        },
      });

    if (!property) {
      throw new NotFoundException(
        'Property not found',
      );
    }

    if (property.hostId === userId) {
      throw new BadRequestException(
        'You cannot start a conversation with yourself',
      );
    }

    /*
     * Booking-related conversation
     */
    if (dto.bookingId) {
      const booking =
        await this.prisma.booking.findFirst({
          where: {
            id: dto.bookingId,
            propertyId: property.id,
            guestId: userId,
          },
        });

      if (!booking) {
        throw new ForbiddenException(
          'You do not have access to this booking',
        );
      }

      const existingConversation =
        await this.prisma.conversation.findUnique({
          where: {
            bookingId: booking.id,
          },
        });

      if (existingConversation) {
        return existingConversation;
      }

      return this.prisma.conversation.create({
        data: {
          propertyId: property.id,
          bookingId: booking.id,
          guestId: userId,
          hostId: property.hostId,
        },
      });
    }

    /*
     * Pre-booking conversation
     */
    if (property.status !== 'ACTIVE') {
      throw new BadRequestException(
        'This property is not currently available for inquiries',
      );
    }

    const existingConversation =
      await this.prisma.conversation.findFirst({
        where: {
          propertyId: property.id,
          guestId: userId,
          hostId: property.hostId,
          bookingId: null,
        },
      });

    if (existingConversation) {
      return existingConversation;
    }

    return this.prisma.conversation.create({
      data: {
        propertyId: property.id,
        guestId: userId,
        hostId: property.hostId,
      },
    });
  }

  async findMine(userId: string) {
    return this.prisma.conversation.findMany({
      where: {
        OR: [
          {
            guestId: userId,
          },
          {
            hostId: userId,
          },
        ],
      },

      orderBy: {
        updatedAt: 'desc',
      },

      include: {
        property: {
          select: {
            id: true,
            title: true,
            city: true,
            state: true,

            images: {
              where: {
                isCover: true,
              },

              take: 1,
            },
          },
        },

        booking: {
          select: {
            id: true,
            checkIn: true,
            checkOut: true,
            status: true,
          },
        },

        guest: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePhotoUrl: true,
          },
        },

        host: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePhotoUrl: true,
          },
        },

        messages: {
          orderBy: {
            createdAt: 'desc',
          },

          take: 1,
        },
      },
    });
  }

  async findOne(
    conversationId: string,
    userId: string,
  ) {
    return this.getAccessibleConversation(
      conversationId,
      userId,
    );
  }

  async findMessages(
    conversationId: string,
    userId: string,
  ) {
    await this.getAccessibleConversation(
      conversationId,
      userId,
    );

    return this.prisma.message.findMany({
      where: {
        conversationId,
      },

      orderBy: {
        createdAt: 'asc',
      },

      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            profilePhotoUrl: true,
          },
        },
      },
    });
  }

  async sendMessage(
    conversationId: string,
    userId: string,
    dto: SendMessageDto,
  ) {
    await this.getAccessibleConversation(
      conversationId,
      userId,
    );

    const message = dto.message.trim();

    if (!message) {
      throw new BadRequestException(
        'Message cannot be empty',
      );
    }

    const createdMessage =
      await this.prisma.message.create({
        data: {
          conversationId,
          senderId: userId,
          message,
        },

        include: {
          sender: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePhotoUrl: true,
            },
          },
        },
      });

    await this.prisma.conversation.update({
      where: {
        id: conversationId,
      },

      data: {
        updatedAt: new Date(),
      },
    });

    return createdMessage;
  }

  async markRead(
    conversationId: string,
    userId: string,
  ) {
    await this.getAccessibleConversation(
      conversationId,
      userId,
    );

    const result =
      await this.prisma.message.updateMany({
        where: {
          conversationId,

          senderId: {
            not: userId,
          },

          readAt: null,
        },

        data: {
          readAt: new Date(),
        },
      });

    return {
      conversationId,
      messagesMarkedRead: result.count,
    };
  }

  private async getAccessibleConversation(
    conversationId: string,
    userId: string,
  ) {
    const conversation =
      await this.prisma.conversation.findFirst({
        where: {
          id: conversationId,

          OR: [
            {
              guestId: userId,
            },
            {
              hostId: userId,
            },
          ],
        },

        include: {
          property: {
            select: {
              id: true,
              title: true,
              city: true,
              state: true,
            },
          },

          booking: {
            select: {
              id: true,
              checkIn: true,
              checkOut: true,
              status: true,
            },
          },

          guest: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePhotoUrl: true,
            },
          },

          host: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePhotoUrl: true,
            },
          },
        },
      });

    if (!conversation) {
      throw new NotFoundException(
        'Conversation not found',
      );
    }

    return conversation;
  }
}