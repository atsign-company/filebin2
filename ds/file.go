package ds

import (
	"time"
)

type File struct {
	Id              int       `json:"-"`
	Bin             string    `json:"bin"`
	Filename        string    `json:"filename"`
	Size            int       `json:"size"`
	Checksum        string    `json:"checksum"`
	Updated         time.Time `json:"updated"`
	UpdatedRelative string    `json:"updated_relative"`
	Created         time.Time `json:"created"`
	CreatedRelative string    `json:"created_relative"`
}
