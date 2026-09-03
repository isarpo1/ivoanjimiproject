import { IsUUID } from 'class-validator';

export class CreateMockPaymentDto {
  @IsUUID('4')
  bookingId: string;
}