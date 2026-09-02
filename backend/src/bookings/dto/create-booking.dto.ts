import {
  IsDateString,
  IsInt,
  IsUUID,
  Min,
} from 'class-validator';

export class CreateBookingDto {
  @IsUUID('4')
  propertyId: string;

  @IsDateString()
  checkIn: string;

  @IsDateString()
  checkOut: string;

  @IsInt()
  @Min(1)
  guestCount: number;
}