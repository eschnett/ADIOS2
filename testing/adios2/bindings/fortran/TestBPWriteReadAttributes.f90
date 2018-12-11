program TestBPWriteAttributes
    use small_test_data
    use mpi
    use adios2
    implicit none

    type(adios2_adios) :: adios
    type(adios2_io) :: ioWrite, ioRead
    type(adios2_engine) :: bpWriter, bpReader
    type(adios2_attribute), dimension(14) :: attributes, attributes_in

    integer :: ierr, i
    integer(kind=1):: i8_value
    integer(kind=2):: i16_value
    integer(kind=4):: i32_value
    integer(kind=8):: i64_value
    real :: r32_value
    real(kind=8):: r64_value

    integer(kind=1), dimension(3):: i8_array
    integer(kind=2), dimension(3):: i16_array
    integer(kind=4), dimension(3):: i32_array
    integer(kind=8), dimension(3):: i64_array
    real, dimension(3) :: r32_array
    real(kind=8), dimension(3):: r64_array


    ! Launch MPI
    call MPI_Init(ierr)

    ! Create adios handler passing the communicator, debug mode and error flag
    call adios2_init(adios, MPI_COMM_WORLD, adios2_debug_mode_on, ierr)

    !!!!!!!!!!!!!!!!!!!!!!!!! WRITER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! Declare an IO process configuration inside adios
    call adios2_declare_io(ioWrite, adios, "ioWrite", ierr)

    do i=1,14
        if( attributes(i)%valid .eqv. .true. ) stop 'Invalid attribute default'
    end do

    ! single value
    call adios2_define_attribute(attributes(1), ioWrite, 'att_String', &
                                 'ADIOS2 String attribute', ierr)

    call adios2_define_attribute(attributes(2), ioWrite, 'att_i8', &
                                 data_I8(1), ierr)

    call adios2_define_attribute(attributes(3), ioWrite, 'att_i16', &
                                 data_I16(1), ierr)

    call adios2_define_attribute(attributes(4), ioWrite, 'att_i32', &
                                 data_I32(1), ierr)

    call adios2_define_attribute(attributes(5), ioWrite, 'att_i64', &
                                 data_I64(1), ierr)

    call adios2_define_attribute(attributes(6), ioWrite, 'att_r32', &
                                 data_R32(1), ierr)

    call adios2_define_attribute(attributes(7), ioWrite, 'att_r64', &
                                 data_R64(1), ierr)

    ! arrays
    call adios2_define_attribute(attributes(8), ioWrite, 'att_Strings_array', &
                                 data_Strings, 3, ierr)

    call adios2_define_attribute(attributes(9), ioWrite, 'att_i8_array', &
                                 data_I8, 3, ierr)

    call adios2_define_attribute(attributes(10), ioWrite, 'att_i16_array', &
                                 data_I16, 3, ierr)

    call adios2_define_attribute(attributes(11), ioWrite, 'att_i32_array', &
                                 data_I32, 3, ierr)

    call adios2_define_attribute(attributes(12), ioWrite, 'att_i64_array', &
                                 data_I64, 3, ierr)

    call adios2_define_attribute(attributes(13), ioWrite, 'att_r32_array', &
                                 data_R32, 3, ierr)

    call adios2_define_attribute(attributes(14), ioWrite, 'att_r64_array', &
                                 data_R64, 3, ierr)

    do i=1,14
        if( attributes(i)%valid .eqv. .false. ) stop 'Invalid adios2_define_attribute'
    end do

    call adios2_open(bpWriter, ioWrite, "fattr_types.bp", adios2_mode_write, &
                     ierr)

    call adios2_close(bpWriter, ierr)

    call MPI_Barrier(MPI_COMM_WORLD, ierr)

    !!!!!!!!!!!!!!!!!!!!!!!!! READER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call adios2_declare_io(ioRead, adios, "ioRead", ierr)

    call adios2_open(bpReader, ioRead, 'fattr_types.bp', adios2_mode_read, ierr)

    call adios2_inquire_attribute(attributes_in(2), ioRead, 'att_i8', ierr)
    call adios2_inquire_attribute(attributes_in(3), ioRead, 'att_i16', ierr)
    call adios2_inquire_attribute(attributes_in(4), ioRead, 'att_i32', ierr)
    call adios2_inquire_attribute(attributes_in(5), ioRead, 'att_i64', ierr)
    call adios2_inquire_attribute(attributes_in(6), ioRead, 'att_r32', ierr)
    call adios2_inquire_attribute(attributes_in(7), ioRead, 'att_r64', ierr)

    if(attributes_in(2)%valid .eqv. .false.) stop 'attribute i8 not found'
    if(attributes_in(2)%type /= adios2_type_integer1) stop 'attribute i8 wrong type'
    if(attributes_in(2)%length /= 1) stop 'attribute i8 lenght is not 1'
    if(attributes_in(2)%is_value .eqv. .false.) stop 'attribute i8 must be value'
    call adios2_attribute_data( i8_value, attributes_in(2), ierr)
    if( i8_value /=  data_I8(1) ) stop 'attribute i8 data error'

    if(attributes_in(3)%valid .eqv. .false.) stop 'attribute i16 not found'
    if(attributes_in(3)%type /= adios2_type_integer2) stop 'attribute i16 wrong type'
    if(attributes_in(3)%length /= 1) stop 'attribute i16 lenght is not 1'
    if(attributes_in(3)%is_value .eqv. .false.) stop 'attribute i16 must be value'
    call adios2_attribute_data( i16_value, attributes_in(3), ierr)
    if( i16_value /=  data_I16(1) ) stop 'attribute i16 data error'

    if(attributes_in(4)%valid .eqv. .false.) stop 'attribute i32 not found'
    if(attributes_in(4)%type /= adios2_type_integer4) stop 'attribute i32 wrong type'
    if(attributes_in(4)%length /= 1) stop 'attribute i32 lenght is not 1'
    if(attributes_in(4)%is_value .eqv. .false.) stop 'attribute i32 must be value'
    call adios2_attribute_data( i32_value, attributes_in(4), ierr)
    if( i32_value /=  data_I32(1) ) stop 'attribute i32 data error'

    if(attributes_in(5)%valid .eqv. .false.) stop 'attribute i64 not found'
    if(attributes_in(5)%type /= adios2_type_integer8) stop 'attribute i64 wrong type'
    if(attributes_in(5)%length /= 1) stop 'attribute i64 lenght is not 1'
    if(attributes_in(5)%is_value .eqv. .false.) stop 'attribute i64 must be value'
    call adios2_attribute_data( i64_value, attributes_in(5), ierr)
    if( i64_value /=  data_I64(1) ) stop 'attribute i64 data error'

    if(attributes_in(6)%valid .eqv. .false.) stop 'attribute r32 not found'
    if(attributes_in(6)%type /= adios2_type_real) stop 'attribute r32 wrong type'
    if(attributes_in(6)%length /= 1) stop 'attribute r32 lenght is not 1'
    if(attributes_in(6)%is_value .eqv. .false.) stop 'attribute r32 must be value'
    call adios2_attribute_data( r32_value, attributes_in(6), ierr)
    if( r32_value /=  data_R32(1) ) stop 'attribute r32 data error'

    if(attributes_in(7)%valid .eqv. .false.) stop 'attribute r64 not found'
    if(attributes_in(7)%type /= adios2_type_dp) stop 'attribute r64 wrong type'
    if(attributes_in(7)%length /= 1) stop 'attribute r64 lenght is not 1'
    if(attributes_in(7)%is_value .eqv. .false.) stop 'attribute r64 must be value'
    call adios2_attribute_data( r64_value, attributes_in(7), ierr)
    if( r64_value /=  data_R64(1) ) stop 'attribute r64 data error'

    ! Array
    call adios2_inquire_attribute(attributes_in(9), ioRead, 'att_i8_array', ierr)
    call adios2_inquire_attribute(attributes_in(10), ioRead, 'att_i16_array', ierr)
    call adios2_inquire_attribute(attributes_in(11), ioRead, 'att_i32_array', ierr)
    call adios2_inquire_attribute(attributes_in(12), ioRead, 'att_i64_array', ierr)
    call adios2_inquire_attribute(attributes_in(13), ioRead, 'att_r32_array', ierr)
    call adios2_inquire_attribute(attributes_in(14), ioRead, 'att_r64_array', ierr)

    if(attributes_in(9)%valid .eqv. .false.) stop 'attribute i8 array not found'
    if(attributes_in(9)%type /= adios2_type_integer1) stop 'attribute i8 array wrong type'
    if(attributes_in(9)%length /= 3) stop 'attribute i8 array lenght is not 1'
    if(attributes_in(9)%is_value .eqv. .true.) stop 'attribute i8 array must be array'
    call adios2_attribute_data( i8_array, attributes_in(9), ierr)
    do i=1,3
       if( i8_array(i) /=  data_I8(i) ) stop 'attribute i8 array data error'
    end do

    if(attributes_in(10)%valid .eqv. .false.) stop 'attribute i16 array not found'
    if(attributes_in(10)%type /= adios2_type_integer2) stop 'attribute i16 array wrong type'
    if(attributes_in(10)%length /= 3) stop 'attribute i16 array lenght is not 1'
    if(attributes_in(10)%is_value .eqv. .true.) stop 'attribute i16 array must be array'
    call adios2_attribute_data( i16_array, attributes_in(10), ierr)
    do i=1,3
       if( i16_array(i) /=  data_I16(i) ) stop 'attribute i16 array data error'
    end do

    if(attributes_in(11)%valid .eqv. .false.) stop 'attribute i32 array not found'
    if(attributes_in(11)%type /= adios2_type_integer4) stop 'attribute i32 array wrong type'
    if(attributes_in(11)%length /= 3) stop 'attribute i32 array lenght is not 1'
    if(attributes_in(11)%is_value .eqv. .true.) stop 'attribute i32 array must be array'
    call adios2_attribute_data( i32_array, attributes_in(11), ierr)
    do i=1,3
       if( i32_array(i) /=  data_I32(i) ) stop 'attribute i32 array data error'
    end do

    if(attributes_in(12)%valid .eqv. .false.) stop 'attribute i64 array not found'
    if(attributes_in(12)%type /= adios2_type_integer8) stop 'attribute i64 array wrong type'
    if(attributes_in(12)%length /= 3) stop 'attribute i64 array lenght is not 1'
    if(attributes_in(12)%is_value .eqv. .true.) stop 'attribute i64 array must be array'
    call adios2_attribute_data( i64_array, attributes_in(12), ierr)
    do i=1,3
       if( i64_array(i) /=  data_I64(i) ) stop 'attribute i64 array data error'
    end do

    if(attributes_in(13)%valid .eqv. .false.) stop 'attribute r32 array not found'
    if(attributes_in(13)%type /= adios2_type_real) stop 'attribute r32 array wrong type'
    if(attributes_in(13)%length /= 3) stop 'attribute r32 array lenght is not 1'
    if(attributes_in(13)%is_value .eqv. .true.) stop 'attribute r32 array must be array'
    call adios2_attribute_data( r32_array, attributes_in(13), ierr)
    do i=1,3
       if( r32_array(i) /=  data_R32(i) ) stop 'attribute r32 array data error'
    end do

    if(attributes_in(14)%valid .eqv. .false.) stop 'attribute r64 array not found'
    if(attributes_in(14)%type /= adios2_type_dp) stop 'attribute r64 array wrong type'
    if(attributes_in(14)%length /= 3) stop 'attribute r64 array lenght is not 1'
    if(attributes_in(14)%is_value .eqv. .true.) stop 'attribute r64 array must be array'
    call adios2_attribute_data( r64_array, attributes_in(14), ierr)
    do i=1,3
       if( r64_array(i) /=  data_R64(i) ) stop 'attribute r64 array data error'
    end do



    call adios2_close(bpReader, ierr)





    call adios2_finalize(adios, ierr)

    call MPI_Finalize(ierr)

end program TestBPWriteAttributes
