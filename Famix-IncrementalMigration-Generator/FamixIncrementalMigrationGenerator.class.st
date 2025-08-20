Class {
	#name : 'FamixIncrementalMigrationGenerator',
	#superclass : 'FamixMetamodelGenerator',
	#instVars : [
		'service',
		'monolith',
		'increment',
		'remoteCall',
		'incrementalMigration'
	],
	#category : 'Famix-IncrementalMigration-Generator',
	#package : 'Famix-IncrementalMigration-Generator'
}

{ #category : 'accessing' }
FamixIncrementalMigrationGenerator class >> packageName [

	<ignoreForCoverage>
	^ #'Famix-IncrementalMigration-Entities'
]

{ #category : 'accessing' }
FamixIncrementalMigrationGenerator class >> prefix [

	<ignoreForCoverage>
	^ #FamixIM
]

{ #category : 'accessing' }
FamixIncrementalMigrationGenerator class >> submetamodels [

	^ { FamixGenerator }
]

{ #category : 'definition' }
FamixIncrementalMigrationGenerator >> defineClasses [

	incrementalMigration := builder
		                        newClassNamed: #IncrementalMigration
		                        comment:
		                        'This entity represents the incremental migration. Referencing increments and data related to the migration.'.
	service := builder
		           newClassNamed: #Service
		           comment:
		           'This entity represents an extracted service, containing the extracted methods and defines the public api methods.'.
	monolith := builder
		            newClassNamed: #Monolith
		            comment:
		            'This entity represents the monolith. We can consider it as a service.'.
	increment := builder
		             newClassNamed: #Increment
		             comment:
		             'This entity represents an increment of the migration. It gives information about extracted services state and monolith state.'.
	remoteCall := builder
		              newClassNamed: #RemoteCall
		              comment:
		              'This entity represents a remote call to a service or the monolith.'
]

{ #category : 'definition' }
FamixIncrementalMigrationGenerator >> defineHierarchy [

	service <|-- monolith
]

{ #category : 'definition' }
FamixIncrementalMigrationGenerator >> defineProperties [

	(increment property: #id type: #Number) comment:
		'Identifier of the increment.'
]

{ #category : 'definition' }
FamixIncrementalMigrationGenerator >> defineRelations [

	((service property: #methods) comment: 'Methods in the service')
	*-*
		(((self remoteTrait: #TMethod withPrefix: #Famix) property:
			  #services) comment: 'Services containing that method').
	(increment property: #nextIncrement)
	- (increment property: #previousIncrement).

	(increment property: #service) - (service property: #increment).

	(increment property: #monolith) - (monolith property: #increment)
]
