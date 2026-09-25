import { IsUUID } from 'class-validator';

export class SaveStayDto {
  @IsUUID('4')
  propertyId: string;
}
