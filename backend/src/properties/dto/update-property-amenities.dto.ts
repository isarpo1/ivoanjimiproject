import {
  ArrayUnique,
  IsArray,
  IsUUID,
} from 'class-validator';

export class UpdatePropertyAmenitiesDto {
  @IsArray()
  @ArrayUnique()
  @IsUUID('4', { each: true })
  amenityIds: string[];
}