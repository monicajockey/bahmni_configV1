SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Gender, age_group, 'Under 5 Seen' AS 'Program_Status'
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- Under 5 CLIENTS SEEN
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 4285 				 
						 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                         AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					     AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id in (
						 select distinct o.person_id from obs o
							where 
								o.concept_id in (4448, 4286, 4450, 4501, 4504, 2379)
								AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
						 )
													
					)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') as under5_seen