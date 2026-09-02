import {
  IsInt,
  IsNumber,
  IsString,
  Min,
  MinLength,
} from 'class-validator';

export class CreatePropertyDto {
  @IsString()
  @MinLength(5)
  title: string;

  @IsString()
  @MinLength(20)
  description: string;

  @IsString()
  address: string;

  @IsString()
  city: string;

  @IsString()
  state: string;

  @IsNumber()
  @Min(0)
  pricePerNight: number;

  @IsInt()
  @Min(1)
  bedrooms: number;

  @IsInt()
  @Min(1)
  bathrooms: number;

  @IsInt()
  @Min(1)
  maxGuests: number;
}