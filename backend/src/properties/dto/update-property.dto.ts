import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
} from 'class-validator';

export class UpdatePropertyDto {
  @IsOptional()
  @IsString()
  @MinLength(5)
  title?: string;

  @IsOptional()
  @IsString()
  @MinLength(20)
  description?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  state?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  pricePerNight?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  bedrooms?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  bathrooms?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  maxGuests?: number;
}