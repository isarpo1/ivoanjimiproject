import {
  IsOptional,
  IsUUID,
} from 'class-validator';

export class CreateConversationDto {
  @IsUUID('4')
  propertyId: string;

  @IsOptional()
  @IsUUID('4')
  bookingId?: string;
}